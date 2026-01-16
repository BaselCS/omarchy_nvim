return {
  {
    "jeryldev/pyworks.nvim",
    dependencies = {
      "benlubas/molten-nvim",
      "3rd/image.nvim",
    },
    -- تأكد من تحميلها مبكراً للتعامل مع ملفات الكود
    lazy = false,
    priority = 100,
    config = function()
      require("pyworks").setup({
        python = {
          use_uv = true, -- استخدام uv لسرعة البرق في التثبيت
          preferred_venv_name = ".venv",
          -- تثبيت المكتبات الأساسية تلقائياً عند إعداد البيئة
          essentials = { "pynvim", "ipykernel", "jupyter_client", "jupytext" },
        },
        image_backend = "kitty", -- غيرها إلى ueberzug إذا كنت لا تستخدم Kitty
      })
    end,
  },
}
