-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


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
