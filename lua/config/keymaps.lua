-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- دالة لتبديل حالة harper-ls
local function toggle_harper()
    local clients = vim.lsp.get_active_clients()
    local harper_active = false
    local harper_client_id = nil
    for _, client in ipairs(clients) do
        if client.name == "harper_ls" then
            harper_active = true
            harper_client_id = client.id
            break
        end
    end
    
    if harper_active then
        vim.lsp.stop_client(harper_client_id)
        print("Harper-LS stopped")
    else
        vim.cmd("LspStart harper_ls")
        print("Harper-LS started")
    end
end

-- إعداد اختصار لوحة المفاتيح (Keybinding)
-- قمت باختيار <leader>th كاختصار (Toggle Harper)
vim.keymap.set('n', '<leader>us', toggle_harper, { desc = 'Toggle Harper-LS' })

-- map <F5> to run the current file with uv
vim.keymap.set("n", "<F5>", function()
  vim.cmd("w")

  local file = vim.fn.expand("%")

  local cmd = "uv run " .. file .. "; echo ''; read -p 'Press ENTER to close...'"

  Snacks.terminal(cmd, {
    cwd = vim.fn.getcwd(),
    win = {
      position = "float",
      width = 0.5,
    },
    interactive = true,
  })
end, { desc = "Run python file (Wait)" })
