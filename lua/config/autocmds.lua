-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
--


-- وظيفة لاكتشاف مسار البايثون في البيئة الافتراضية
-- local function get_python_path()
--   local venv_path = vim.fn.getcwd() .. "/.venv" -- افتراض أن الاسم هو .venv
--   if vim.fn.executable(venv_path .. "/bin/python") == 1 then
--     return venv_path .. "/bin/python"
--   end
--   -- العودة للبايثون الافتراضي في النظام إذا لم يجد البيئة
--   return "python3"
-- end

-- -- إعداد Pyright (كمثال) لاستخدام المسار المكتشف
-- require('lspconfig').pyright.setup({
--   on_init = function(client)
--     client.config.settings.python.pythonPath = get_python_path()
--   end
-- })
