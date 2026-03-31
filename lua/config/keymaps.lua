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
-- قمت باختيار <leader>th كاختصار (Toggle Harper)
vim.keymap.set('n', '<leader>us', toggle_harper, { desc = 'Toggle Harper-LS' })

-- دالة لتبديل Copilot
local function toggle_copilot()
  vim.cmd('Copilot toggle')
  print("Copilot toggled")
end

-- Toggle Copilot on/off
vim.keymap.set('n', '<leader>cc', toggle_copilot, { desc = 'Toggle Copilot' })
