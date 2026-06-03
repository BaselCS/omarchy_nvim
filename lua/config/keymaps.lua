-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- دالة لتبديل حالة harper-ls
local function toggle_harper()
	local clients = vim.lsp.get_clients({ name = "harper_ls" })
	local has_running_client = #clients > 0

	if has_running_client then
		vim.lsp.enable("harper_ls", false)
		for _, client in ipairs(clients) do
			vim.lsp.stop_client(client.id)
		end
		print("Harper-LS stopped")
	else
		vim.lsp.enable("harper_ls", true)
		vim.cmd("LspStart harper_ls")
		print("Harper-LS started")
	end
end

-- إعداد اختصار لوحة المفاتيح (Keybinding)
-- قمت باختيار <leader>us كاختصار (Toggle Harper)
vim.keymap.set("n", "<leader>us", toggle_harper, { desc = "Toggle Harper-LS" })

-- دالة لتبديل Copilot
local function toggle_copilot()
	vim.cmd("Copilot toggle")
	print("Copilot toggled")
end

-- Toggle Copilot on/off
vim.keymap.set("n", "<leader>ac", toggle_copilot, { desc = "Toggle Copilot" })

-- Run current Python file with F5 in a floating terminal.
vim.keymap.set("n", "<leader>rp", function()
	local file = vim.fn.expand("%:p")
	if file == nil or file == "" then
		vim.notify("No file to run", vim.log.levels.WARN)
		return
	end

	-- Save buffer if modified before running
	if vim.bo.modified then
		local ok, err = pcall(vim.cmd, "write")
		if ok then
			vim.notify("Saved " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
		else
			vim.notify("Failed to save file: " .. tostring(err), vim.log.levels.ERROR)
			return
		end
	end

	-- Create floating buffer and window
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.max(40, math.floor(vim.o.columns * 0.8))
	local height = math.max(10, math.floor(vim.o.lines * 0.6))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
	local ok, win = pcall(vim.api.nvim_open_win, buf, true, win_opts)
	if not ok then
		vim.notify("Failed to open floating window", vim.log.levels.ERROR)
		return
	end

	vim.notify("Running: " .. file, vim.log.levels.INFO)
	local term = vim.fn.termopen("python " .. vim.fn.shellescape(file), {
		on_exit = function(_, code, _)
			vim.schedule(function()
				local close_fn = function()
					if vim.api.nvim_win_is_valid(win) then
						pcall(vim.api.nvim_win_close, win, true)
					end
				end

				vim.notify(
					"Process exited with code: " .. tostring(code) .. " — press Enter, q, or Q to close",
					vim.log.levels.INFO
				)
				-- leave terminal open and switch to normal mode so user can move around
				pcall(vim.cmd, "stopinsert")

				-- set buffer-local mappings to close the floating window with Enter, q or Q
				pcall(vim.keymap.set, "n", "<CR>", close_fn, { buffer = buf, silent = true })
				pcall(vim.keymap.set, "n", "q", close_fn, { buffer = buf, silent = true })
				pcall(vim.keymap.set, "n", "Q", close_fn, { buffer = buf, silent = true })

				-- move cursor to end so output is visible
				if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) then
					local lines = vim.api.nvim_buf_line_count(buf)
					pcall(vim.api.nvim_win_set_cursor, win, { lines, 0 })
				end
			end)
		end,
	})
	if term == 0 then
		vim.notify("Failed to start terminal job", vim.log.levels.ERROR)
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
		return
	end
	vim.cmd("startinsert")
end, { desc = "Run current Python file (F5)", silent = false })

-- الخروج من وضع الإدخال في الطرفية باستخدام jj
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })
