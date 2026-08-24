local function auto_discover_vm_service(callback)
	local vm_service = require("flutter-tools.vm_service")
	if vm_service.is_connected() then
		if callback then callback() end
		return
	end

	local handle = io.popen("ps aux | grep -oE 'http://127.0.0.1:[0-9]+/[^ /]+' | head -n 1")
	if not handle then return end
	local url = handle:read("*l")
	handle:close()

	if url and url:match("^http://127%.0%.0%.1:%d+/") then
		vm_service.connect(url, function()
			vim.schedule(function()
				vim.notify("󰈤 Connected to Flutter VM Service (Tap-to-jump active)", vim.log.levels.INFO, { title = "Flutter" })
				if callback then callback() end
			end)
		end)
	end
end

local function toggle_inspect_widget()
	local vm_service = require("flutter-tools.vm_service")
	if not vm_service.is_connected() then
		auto_discover_vm_service(function()
			vm_service.toggle_inspector()
		end)
	else
		vm_service.toggle_inspector()
	end
end

local function run_dart_fix(current_file_only)
	local target = current_file_only and vim.api.nvim_buf_get_name(0) or "."
	local cmd = { "dart", "fix", "--apply" }
	if current_file_only and target and target ~= "" then
		table.insert(cmd, target)
	end

	vim.notify("Running dart fix --apply...", vim.log.levels.INFO, { title = "Dart Fix" })

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code, _)
			if code == 0 then
				vim.notify("✨ Dart Fix Applied! (const, containers, lints auto-fixed)", vim.log.levels.INFO, { title = "Dart Fix" })
				vim.cmd("checktime")
			else
				vim.notify("Dart fix finished with warnings.", vim.log.levels.WARN, { title = "Dart Fix" })
			end
		end,
	})
end

local function apply_fix_all_on_save(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "dartls" })
	if #clients == 0 then return end
	local client = clients[1]

	local file = vim.api.nvim_buf_get_name(bufnr)
	if not file or file == "" or not file:match("%.dart$") then return end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local params = {
		textDocument = { uri = vim.uri_from_bufnr(bufnr) },
		range = {
			start = { line = 0, character = 0 },
			["end"] = { line = math.max(0, line_count - 1), character = 0 },
		},
		context = {
			only = { "source.fixAll" },
			diagnostics = {},
		},
	}

	local ok_req, res = pcall(vim.lsp.buf_request_sync, bufnr, "textDocument/codeAction", params, 600)
	if not ok_req or not res then return end

	for _, client_res in pairs(res) do
		if client_res.result and not client_res.error then
			for _, action in ipairs(client_res.result) do
				if action.command then
					pcall(function() client:exec_cmd(action.command, { bufnr = bufnr }) end)
				elseif action.edit then
					pcall(vim.lsp.util.apply_workspace_edit, action.edit, client.offset_encoding)
				end
			end
		end
	end
end

-- Filter out -32007 "File is not being analyzed" error notifications
local _notify = vim.notify
vim.notify = function(msg, level, opts)
	if type(msg) == "string" and (msg:match("%-32007") or msg:match("File is not being analyzed")) then
		return
	end
	return _notify(msg, level, opts)
end

return {
	{
		"akinsho/flutter-tools.nvim",
		lazy = false,
		ft = { "dart" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			ui = {
				border = "rounded",
				notification_style = "native",
			},
			decorations = {
				status_bar = {
					device = true,
					app_version = true,
				},
			},
			widget_guides = {
				enabled = true,
			},
			closing_tags = {
				highlight = "Comment",
				prefix = "// ",
				enabled = true,
			},
			dev_log = {
				enabled = true,
				filter = nil,
				notify_errors = false,
				open_cmd = "tabedit",
				focus_on_open = true,
				auto_flush = true,
			},
			dev_tools = {
				autostart = false,
				auto_open_browser = false,
			},
			outline = {
				open_cmd = "35vnew",
				auto_open = false,
			},
			debugger = {
				enabled = true,
				run_via_dap = true,
				register_configurations = function(_)
					require("dap").configurations.dart = {}
					require("dap.ext.vscode").load_launchjs()
				end,
			},
			lsp = {
				color = {
					enabled = true,
					background = false,
					foreground = false,
					virtual_text = true,
					virtual_text_str = "■",
				},
				on_attach = function(client, bufnr)
					-- 1. Auto-add const and fix lints before and after save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							pcall(apply_fix_all_on_save, bufnr)
						end,
					})

					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						callback = function()
							local file = vim.api.nvim_buf_get_name(bufnr)
							if file and file ~= "" and file:match("%.dart$") then
								vim.fn.jobstart({ "dart", "fix", "--apply", file }, {
									on_exit = function(_, code)
										if code == 0 then
											vim.schedule(function()
												if vim.api.nvim_buf_is_valid(bufnr) then
													vim.cmd("checktime " .. bufnr)
												end
											end)
										end
									end,
								})
							end
						end,
					})

					-- 2. Configure diagnostics display (VS Code style inline hints & float)
					vim.diagnostic.config({
						virtual_text = {
							prefix = "●",
							source = "if_many",
						},
						float = {
							border = "rounded",
							source = "always",
							header = " 🚨 Problem Details ",
							prefix = " ",
						},
						signs = true,
						underline = true,
						update_in_insert = false,
						severity_sort = true,
					}, bufnr)

					-- 3. Enable inlay hints for Dart
					if vim.lsp.inlay_hint and client.supports_method("textDocument/inlayHint") then
						pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
					end

					-- 4. Auto show problem popup window on cursor pause (VS Code style)
					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = bufnr,
						callback = function()
							pcall(vim.diagnostic.open_float, bufnr, {
								focusable = false,
								close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
								border = "rounded",
								source = "always",
								scope = "line",
							})
						end,
					})
				end,
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					enableSnippets = true,
					updateImportsOnRename = true,
					enableSdkFormatter = true,
					documentation = "full",
					suggestFromUnimportedLibraries = true,
					closingLabels = true,
					includeDependenciesInWorkspaceSymbols = true,
					lineLength = 120,
				},
			},
		},
		config = function(_, opts)
			require("flutter-tools").setup(opts)

			-- Auto-scan for VM service on interval
			local timer = vim.uv.new_timer()
			timer:start(1000, 3000, vim.schedule_wrap(function()
				local vm_service = require("flutter-tools.vm_service")
				if not vm_service.is_connected() then
					auto_discover_vm_service()
				end
			end))

			-- DAP output / uri listeners
			local dap_ok, dap = pcall(require, "dap")
			if dap_ok and dap.listeners then
				dap.listeners.after.event_dart_debuggerUris = dap.listeners.after.event_dart_debuggerUris or {}
				dap.listeners.after.event_dart_debuggerUris["flutter_auto_jump"] = function(_, body)
					if body and body.vmServiceUri then
						require("flutter-tools.vm_service").connect(body.vmServiceUri)
					end
				end

				dap.listeners.after.event_output = dap.listeners.after.event_output or {}
				dap.listeners.after.event_output["flutter_runtime_error_popup"] = function(_, body)
					if body and body.output then
						local text = body.output
						if text:match("EXCEPTION CAUGHT") or text:match("Unhandled exception:") or text:match("Exception:") or text:match("Assertion failed:") then
							pcall(require("flutter-tools.vm_service").handle_stderr_error_event, text)
						end
					end
				end
			end
		end,
		keys = {
			{ "<leader>F", "", desc = "+Flutter", mode = { "n", "v" } },
			{ "<leader>Fs", "<cmd>FlutterRun<cr>", desc = "Flutter Run (Start)" },
			{ "<leader>Fr", "<cmd>FlutterReload<cr>", desc = "Flutter Hot Reload" },
			{ "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter Hot Restart" },
			{ "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
			{ "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Select Device" },
			{ "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter Emulators" },
			{ "<leader>Fi", toggle_inspect_widget, desc = "Toggle Tap-to-Inspect Widget Mode on Device" },
			{ "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter Widget Tree Outline" },
			{ "<leader>Ft", "<cmd>FlutterDevTools<cr>", desc = "Flutter Open DevTools Browser" },
			{ "<leader>Fl", "<cmd>FlutterLogToggle<cr>", desc = "Flutter Toggle Dev Log" },
			{ "<leader>Fp", "<cmd>FlutterPubGet<cr>", desc = "Flutter Pub Get" },
			{ "<leader>FP", "<cmd>FlutterPubUpgrade<cr>", desc = "Flutter Pub Upgrade" },
			{ "<leader>Ff", function() run_dart_fix(true) end, desc = "Dart Fix: Auto-fix current file" },
			{ "<leader>FF", function() run_dart_fix(false) end, desc = "Dart Fix: Auto-fix entire project" },
			{ "<leader>Fw", function()
				vim.lsp.buf.code_action({
					filter = function(action)
						local title = action.title:lower()
						return title:match("wrap") or title:match("remove") or title:match("extract") or title:match("const")
					end,
					apply = false,
				})
			end, desc = "Flutter Quick Wrap / Widget Action" },
		},
	},
}
