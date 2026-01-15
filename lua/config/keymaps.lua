-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- `z-` for Harper
vim.keymap.set("n", "z=", function()
  -- التأكد من وجود Telescope أولاً
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.lsp_code_actions(require("telescope.themes").get_cursor({
      layout_config = {
        width = 0.3,                       -- عرض القائمة (30% من الشاشة)
        height = 0.2,                      -- طول القائمة
      },
      prompt_title = "Harper Suggestions", -- عنوان القائمة
    }))
  else
    -- إذا لم يكن Telescope متاحاً، استخدم الأمر الافتراضي
    vim.lsp.buf.code_action()
  end
end, { desc = "Harper Quick Fix (Simple Cursor Layout)" })


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
