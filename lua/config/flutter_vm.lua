--- VM Service WebSocket client for Flutter/Dart debugging
--- WebSocket framing per RFC 6455
local uv = vim.uv

local M = {}

local OPCODE_TEXT = 1
local OPCODE_CLOSE = 8
local OPCODE_PING = 9

local tcp = nil
local connected = false
local handshake_complete = false
local request_id = 0
local pending_requests = {}
local event_handlers = {}
local read_buffer = ""
local active_isolate_id = nil
local query_debounce_timer = nil

local function log_debug(msg)
  local f = io.open("/tmp/nvim_flutter_debug.log", "a")
  if f then
    f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(msg) .. "\n")
    f:close()
  end
end

local function generate_handshake(host, port, path)
  local lines = {
    "GET " .. path .. " HTTP/1.1",
    "Host: " .. host .. ":" .. port,
    "Upgrade: websocket",
    "Connection: Upgrade",
    "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==",
    "Sec-WebSocket-Version: 13",
    "",
    "",
  }
  return table.concat(lines, "\r\n")
end

local function generate_mask_key()
  return {
    math.random(0, 255),
    math.random(0, 255),
    math.random(0, 255),
    math.random(0, 255),
  }
end

local function mask_payload(payload, key)
  local masked = {}
  for i = 1, #payload do
    local byte = string.byte(payload, i, i)
    local mask_byte = key[((i - 1) % 4) + 1]
    table.insert(masked, string.char(bit.bxor(byte, mask_byte)))
  end
  return table.concat(masked, "")
end

local function create_frame(payload)
  local key = generate_mask_key()
  local len = #payload
  local frame = {}

  table.insert(frame, string.char(0x81))

  if len < 126 then
    table.insert(frame, string.char(0x80 + len))
  elseif len < 65536 then
    table.insert(frame, string.char(0x80 + 126))
    table.insert(frame, string.char(bit.rshift(len, 8)))
    table.insert(frame, string.char(bit.band(len, 0xFF)))
  else
    table.insert(frame, string.char(0x80 + 127))
    for i = 7, 0, -1 do
      table.insert(frame, string.char(bit.band(bit.rshift(len, i * 8), 0xFF)))
    end
  end

  for _, k in ipairs(key) do
    table.insert(frame, string.char(k))
  end

  table.insert(frame, mask_payload(payload, key))

  return table.concat(frame, "")
end

local function parse_frame(data)
  if #data < 2 then return nil, data end

  local b1 = string.byte(data, 1)
  local b2 = string.byte(data, 2)

  local opcode = bit.band(b1, 0x0F)
  local payload_len = bit.band(b2, 0x7F)

  local header_len = 2
  if payload_len == 126 then
    if #data < 4 then return nil, data end
    payload_len = bit.lshift(string.byte(data, 3), 8) + string.byte(data, 4)
    header_len = 4
  elseif payload_len == 127 then
    if #data < 10 then return nil, data end
    payload_len = 0
    for i = 3, 10 do
      payload_len = bit.lshift(payload_len, 8) + string.byte(data, i)
    end
    header_len = 10
  end

  local has_mask = bit.band(b2, 0x80) > 0
  if has_mask then header_len = header_len + 4 end

  local total_len = header_len + payload_len
  if #data < total_len then return nil, data end

  local payload = data:sub(header_len + 1, total_len)
  local remaining = data:sub(total_len + 1)

  return { opcode = opcode, payload = payload }, remaining
end

local function jump_to_file_line(file, line)
  if not file or not line then return end
  file = file:gsub("^file://", "")
  file = file:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  log_debug("Attempting jump to: " .. tostring(file) .. ":" .. tostring(line))

  if vim.fn.filereadable(file) == 1 then
    vim.schedule(function()
      local bufnr = vim.fn.bufadd(file)
      vim.fn.bufload(bufnr)
      vim.api.nvim_set_current_buf(bufnr)
      local target_line = math.max(1, tonumber(line) or 1)
      pcall(vim.api.nvim_win_set_cursor, 0, { target_line, 0 })
      vim.cmd("normal! zz")
      vim.notify("🎯 Clicked widget: " .. vim.fs.basename(file) .. ":" .. target_line, vim.log.levels.INFO, { title = "Flutter Inspector" })
      pcall(vim.fn.system, { "hyprctl", "dispatch", "focuswindow", "class:com.mitchellh.ghostty" })
    end)
  else
    log_debug("File not readable: " .. tostring(file))
  end
end

local function find_local_location(tbl, depth)
  if type(tbl) ~= "table" or (depth or 0) > 15 then return nil end

  if tbl.createdByLocalProject and tbl.creationLocation then
    local loc = tbl.creationLocation
    if (loc.file or loc.path or loc.uri) and loc.line then
      return loc.file or loc.path or loc.uri, loc.line
    end
  end

  local loc = tbl.creationLocation or tbl.location
  if loc and (loc.file or loc.path or loc.uri) and loc.line then
    local f = loc.file or loc.path or loc.uri
    if not f:match("/packages/flutter/") and not f:match("/flutter/packages/flutter/") then
      return f, loc.line
    end
  end

  for _, v in pairs(tbl) do
    local f, l = find_local_location(v, (depth or 0) + 1)
    if f and l then return f, l end
  end
  return nil
end

local function perform_inspector_query()
  if not connected then
    log_debug("perform_inspector_query skipped: not connected")
    return
  end

  local function do_query(iso_id)
    log_debug("perform_inspector_query: querying isolate " .. tostring(iso_id))
    M.request("ext.flutter.inspector.getSelectedSummaryWidget", {
      isolateId = iso_id,
      objectGroup = "temp",
    }, function(err, result)
      log_debug("getSelectedSummaryWidget: err=" .. tostring(err) .. " has_res=" .. tostring(result ~= nil))
      if not err and result then
        local f, l = find_local_location(result)
        if f and l then
          jump_to_file_line(f, l)
          return
        end
      end

      M.request("ext.flutter.inspector.getSelectedWidget", {
        isolateId = iso_id,
        objectGroup = "temp",
      }, function(err2, result2)
        log_debug("getSelectedWidget: err2=" .. tostring(err2) .. " has_res=" .. tostring(result2 ~= nil))
        if not err2 and result2 then
          local f2, l2 = find_local_location(result2)
          if f2 and l2 then
            jump_to_file_line(f2, l2)
          end
        end
      end)
    end)
  end

  if active_isolate_id then
    do_query(active_isolate_id)
  else
    M.request("getVM", nil, function(err, vm)
      if not err and vm and vm.isolates and #vm.isolates > 0 then
        active_isolate_id = vm.isolates[1].id
        do_query(active_isolate_id)
      else
        log_debug("getVM failed: " .. tostring(err))
      end
    end)
  end
end

local function trigger_inspector_query()
  if query_debounce_timer then
    pcall(function() query_debounce_timer:stop() end)
  end
  query_debounce_timer = vim.defer_fn(function()
    perform_inspector_query()
  end, 20)
end

local function show_runtime_error_popup(data)
  if not data then return end

  local summary = nil
  local hint = nil
  local file_loc = nil
  local line_num = nil
  local stack_lines = {}

  if data.properties and type(data.properties) == "table" then
    for _, prop in ipairs(data.properties) do
      if prop.type == "ErrorSummary" then
        summary = prop.description
      elseif prop.type == "ErrorHint" then
        hint = prop.description
      elseif prop.type == "ErrorDescription" and not summary then
        summary = prop.description
      elseif prop.type == "DiagnosticsStackTrace" and prop.properties then
        for _, st in ipairs(prop.properties) do
          local desc = st.description or ""
          local file, lnum = desc:match("package:[^/]+/(.+)%:(%d+)")
          if not file then
            file, lnum = desc:match("(%S+%.dart)%:(%d+)")
          end
          if file and lnum and not file_loc then
            if not file:match("^flutter/") and not file:match("/packages/flutter/") then
              file_loc = file
              line_num = tonumber(lnum)
            end
          end
          if #stack_lines < 6 and desc ~= "" then
            table.insert(stack_lines, "  " .. desc)
          end
        end
      end
    end
  end

  summary = summary or data.description or "Flutter Runtime Exception"

  local content = {}
  table.insert(content, "")
  table.insert(content, "  🚨 Runtime Exception: " .. summary)
  table.insert(content, "")

  if file_loc and line_num then
    table.insert(content, "  📍 Location: " .. file_loc .. ":" .. line_num)
    table.insert(content, "")
  end

  if hint then
    table.insert(content, "  💡 Hint: " .. hint:gsub("\n", " "))
    table.insert(content, "")
  end

  if #stack_lines > 0 then
    table.insert(content, "  📚 Stack Trace:")
    for _, st in ipairs(stack_lines) do
      table.insert(content, st)
    end
    table.insert(content, "")
  end

  table.insert(content, "  ─────────────────────────────────────────────────────────────")
  table.insert(content, "  [<Enter> Jump to Code]           [<Esc> / q Close Window]    ")

  vim.schedule(function()
    if Snacks and Snacks.win then
      local function on_jump(self)
        self:close()
        if file_loc and line_num then
          local full_path = file_loc
          if not full_path:match("^/") then
            full_path = vim.fn.getcwd() .. "/lib/" .. file_loc
            if vim.fn.filereadable(full_path) == 0 then
              full_path = vim.fn.getcwd() .. "/" .. file_loc
            end
          end
          if vim.fn.filereadable(full_path) == 1 then
            local bufnr = vim.fn.bufadd(full_path)
            vim.fn.bufload(bufnr)
            vim.api.nvim_set_current_buf(bufnr)
            pcall(vim.api.nvim_win_set_cursor, 0, { line_num, 0 })
            vim.cmd("normal! zz")
          end
        end
      end

      Snacks.win({
        text = content,
        width = 0.75,
        height = math.min(22, #content + 2),
        border = "rounded",
        title = " 🚨 Flutter Runtime Problem ",
        title_pos = "center",
        keys = {
          ["<CR>"] = on_jump,
          ["<Enter>"] = on_jump,
          q = "close",
          ["<Esc>"] = "close",
        },
      })
    else
      vim.notify("🚨 Flutter Runtime Error: " .. summary, vim.log.levels.ERROR, { title = "Flutter Error" })
    end
  end)
end

local last_error_popup_time = 0

local function handle_stderr_error_event(text)
  if not text or text == "" then return end
  local now = vim.uv.now()
  if now - last_error_popup_time < 1200 then return end

  local summary = text:match("EXCEPTION CAUGHT BY ([^\n═]+)")
  if summary then
    summary = "Exception caught by " .. vim.trim(summary)
  else
    summary = text:match("Unhandled exception:%s*([^\n]+)") or text:match("Exception:%s*([^\n]+)") or text:match("Assertion failed:%s*([^\n]+)") or "Flutter Runtime Exception"
  end

  local file_loc, line_num = text:match("package:[^/]+/(%S+%.dart)%:(%d+)")
  if not file_loc then
    file_loc, line_num = text:match("(%S+%.dart)%:(%d+)")
  end

  local hint = text:match("The relevant error%-causing widget was:%s*([^\n]+)")
    or text:match("Either the assertion indicates an error in the framework itself[^\n]+")

  show_runtime_error_popup({
    description = summary,
    properties = {
      { type = "ErrorSummary", description = summary },
      hint and { type = "ErrorHint", description = hint } or nil,
      file_loc and {
        type = "DiagnosticsStackTrace",
        properties = {
          { description = file_loc .. ":" .. tostring(line_num) }
        }
      } or nil,
    }
  })
end

local function handle_builtin_extension_event(event)
  if not event then return end

  if event.isolate and event.isolate.id then
    active_isolate_id = event.isolate.id
  end

  local kind = event.extensionKind or event.kind
  local data = event.extensionData or event.inspectee or {}

  if kind == "Flutter.Frame" or kind == "Flutter.FirstFrame" or kind == "Flutter.FrameworkInitialization" then
    return
  end

  log_debug("Event received: kind=" .. tostring(kind))

  if kind == "Flutter.Error" then
    show_runtime_error_popup(data)
    return
  end

  local f, l = find_local_location(data)
  if f and l then
    jump_to_file_line(f, l)
    return
  end

  if kind == "Flutter.Inspect" or kind == "Flutter.SelectedWidget" or kind == "Flutter.Widget" or kind == "Inspect" or kind == "Flutter.ServiceExtensionStateChanged" or kind == "PausePostRequest" then
    trigger_inspector_query()
  end
end

local function handle_message(message)
  local ok, data = pcall(vim.json.decode, message)
  if not ok then return end

  if data.id and pending_requests[data.id] then
    local callback = pending_requests[data.id]
    pending_requests[data.id] = nil
    vim.schedule(function() callback(data.error, data.result) end)
    return
  end

  if data.method == "streamNotify" and data.params then
    local stream_id = data.params.streamId
    local event = data.params.event
    if event and event.extensionKind ~= "Flutter.Frame" and event.extensionKind ~= "Flutter.FirstFrame" then
      log_debug("streamNotify [" .. tostring(stream_id) .. "] event=" .. vim.inspect(event))
    end

    if stream_id == "Stderr" and event and event.bytes then
      local ok_b64, text = pcall(vim.base64.decode, event.bytes)
      if ok_b64 and text and (text:match("EXCEPTION CAUGHT") or text:match("Unhandled exception:") or text:match("Exception:") or text:match("Assertion failed:")) then
        handle_stderr_error_event(text)
      end
    elseif stream_id == "Logging" and event and event.logRecord and event.logRecord.message and event.logRecord.message.valueAsString then
      local text = event.logRecord.message.valueAsString
      if text:match("EXCEPTION CAUGHT") or text:match("Unhandled exception:") or text:match("Exception:") then
        handle_stderr_error_event(text)
      end
    elseif stream_id == "Extension" or stream_id == "Debug" or stream_id == "Isolate" then
      handle_builtin_extension_event(event)
    end

    local handler = event_handlers[stream_id]
    if handler and type(handler) == "function" then
      vim.schedule(function() pcall(handler, event) end)
    end
  end
end

local function parse_uri(uri)
  if not uri then return nil, nil, nil end

  local query_uri = uri:match("[?&]uri=([^&]+)")
  if query_uri then
    uri = query_uri:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  end

  uri = uri:gsub("%?.*$", "")
  uri = uri:gsub("/devtools/?$", "")

  local protocol, rest = uri:match("^(wss?)://(.+)$")
  if not protocol then
    protocol, rest = uri:match("^(https?)://(.+)$")
  end
  if not rest then return nil, nil, nil end

  local host_port, path = rest:match("^([^/]+)(/.*)$")
  if not host_port then
    host_port = rest
    path = "/"
  end

  local host, port = host_port:match("^([^:]+):(%d+)$")
  if not host then
    host = host_port
    port = (protocol == "wss" or protocol == "https") and 443 or 80
  end

  if not path:match("/ws$") then path = path:gsub("/$", "") .. "/ws" end

  return host, tonumber(port), path
end

local function on_connection_established()
  M.request("getVM", nil, function(err, vm)
    if not err and vm and vm.isolates and #vm.isolates > 0 then
      active_isolate_id = vm.isolates[1].id
      M.request("ext.flutter.inspector.setPubRootDirectories", {
        isolateId = active_isolate_id,
        arg0 = "file://" .. vim.fn.getcwd(),
      })
    end
  end)

  M.stream_listen("Extension", function() end)
  M.stream_listen("Debug", function() end)
  M.stream_listen("Isolate", function() end)
  M.stream_listen("Stderr", function() end)
  M.stream_listen("Logging", function() end)
end

function M.connect(uri, on_connect, on_error)
  if connected then M.disconnect() end

  local host, port, path = parse_uri(uri)
  if not host or not port then
    if on_error then on_error("Invalid URI: " .. tostring(uri)) end
    return
  end

  tcp = uv.new_tcp()
  handshake_complete = false
  read_buffer = ""

  tcp:connect(host, port, function(err)
    if err then
      vim.schedule(function()
        if on_error then on_error("Connection failed: " .. tostring(err)) end
      end)
      return
    end

    tcp:write(generate_handshake(host, port, path))

    tcp:read_start(function(read_err, chunk)
      if read_err then
        vim.schedule(function()
          if on_error then on_error("Read error: " .. tostring(read_err)) end
        end)
        M.disconnect()
        return
      end

      if not chunk then
        M.disconnect()
        return
      end

      if not handshake_complete then
        if chunk:match("HTTP/1.1 101") then
          handshake_complete = true
          connected = true
          on_connection_established()
          vim.schedule(function()
            if on_connect then on_connect() end
          end)
          return
        elseif chunk:match("HTTP/1.1 302") or chunk:match("HTTP/1.1 301") then
          local redirect_url = chunk:match("[Ll]ocation:%s*([^\r\n]+)")
          if redirect_url then
            M.disconnect()
            vim.defer_fn(function()
              M.connect(redirect_url, on_connect, on_error)
            end, 50)
            return
          end
        end
        return
      end

      read_buffer = read_buffer .. chunk
      while true do
        local frame, remaining = parse_frame(read_buffer)
        if not frame then break end
        read_buffer = remaining

        if frame.opcode == OPCODE_TEXT then
          handle_message(frame.payload)
        elseif frame.opcode == OPCODE_PING then
          local key = generate_mask_key()
          local pong_frame = {
            string.char(0x8A),
            string.char(0x80 + #frame.payload),
          }
          for _, k in ipairs(key) do
            table.insert(pong_frame, string.char(k))
          end
          table.insert(pong_frame, mask_payload(frame.payload, key))
          tcp:write(table.concat(pong_frame, ""))
        elseif frame.opcode == OPCODE_CLOSE then
          M.disconnect()
          return
        end
      end
    end)
  end)
end

function M.request(method, params, callback)
  if not connected or not tcp then
    if callback then callback("Not connected", nil) end
    return
  end

  request_id = request_id + 1
  local id = tostring(request_id)

  local rpc_params = params
  if not rpc_params or next(rpc_params) == nil then
    rpc_params = vim.empty_dict()
  end

  local message = vim.json.encode({
    jsonrpc = "2.0",
    id = id,
    method = method,
    params = rpc_params,
  })

  if callback then pending_requests[id] = callback end

  tcp:write(create_frame(message))
end

function M.stream_listen(stream_id, handler, callback)
  event_handlers[stream_id] = handler
  M.request("streamListen", { streamId = stream_id }, callback)
end

function M.is_connected() return connected end

function M.toggle_inspector()
  local function send_show(iso)
    M.request("ext.flutter.inspector.show", {
      enabled = "true",
      isolateId = iso,
    }, function(err, res)
      vim.schedule(function()
        vim.notify("🎯 Inspect Mode Active: Tap any widget on device screen to jump in code", vim.log.levels.INFO, { title = "Flutter" })
      end)
    end)
  end

  local function do_enable()
    if active_isolate_id then
      send_show(active_isolate_id)
    else
      M.request("getVM", nil, function(err, vm)
        if not err and vm and vm.isolates and #vm.isolates > 0 then
          active_isolate_id = vm.isolates[1].id
          send_show(active_isolate_id)
        end
      end)
    end
  end

  if not connected then
    local handle = io.popen("ps aux | grep -oE 'http://127.0.0.1:[0-9]+/[^ /]+' | head -n 1")
    if handle then
      local url = handle:read("*l")
      handle:close()
      if url and url:match("^http://127%.0%.0%.1:") then
        M.connect(url, function()
          vim.defer_fn(do_enable, 150)
        end)
        return
      end
    end
  end

  do_enable()
end

function M.disconnect()
  connected = false
  handshake_complete = false
  active_isolate_id = nil

  for _, callback in pairs(pending_requests) do
    vim.schedule(function() callback("Service connection closed", nil) end)
  end
  pending_requests = {}
  event_handlers = {}
  read_buffer = ""

  if tcp then
    if not tcp:is_closing() then
      tcp:read_stop()
      tcp:close()
    end
    tcp = nil
  end
end

M.show_runtime_error_popup = show_runtime_error_popup
M.handle_stderr_error_event = handle_stderr_error_event

return M
