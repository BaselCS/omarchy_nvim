return {
  -- 1. تعديل إعدادات Copilot الأساسية لتفعيل Ghost Text
  {
    "zbirenbaum/copilot.lua",
    cmd = { "Copilot" },
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<S-CR>",
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-c>",
          toggle_auto_trigger = "<A-CR>",
        },
      },
      filetypes = {
        ["*"] = true,
      },
    },
  },

  -- 2. إخفاء Copilot من القائمة المنبثقة (LSP Menu) لمنع التكرار
  -- (إذا كنت تستخدم blink.cmp وهو الافتراضي الجديد في LazyVim)
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        -- نمنع blink من عرض اقتراحات copilot في القائمة
        providers = {
          copilot = { enabled = false },
        },
      },
    },
  },

  -- (أو إذا كنت تستخدم nvim-cmp القديم)
  {
    "nvim-cmp",
    optional = true,
    opts = function(_, opts)
      -- إزالة copilot من مصادر القائمة
      opts.sources = vim.tbl_filter(function(v)
        return v.name ~= "copilot"
      end, opts.sources)
    end,
  },
}
