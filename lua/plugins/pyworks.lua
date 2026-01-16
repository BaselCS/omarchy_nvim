return {
  {
    "jeryldev/pyworks.nvim",
    dependencies = {
      "benlubas/molten-nvim",
      "3rd/image.nvim",
    },
    lazy = false,
    priority = 100,
    config = function()
      require("pyworks").setup({
        python = {
          use_uv = true,
          preferred_venv_name = ".venv",
          auto_install_essentials = true,
          essentials = { "pynvim", "ipykernel", "jupyter_client", "jupytext" },
        },
        preferred_venv_name = ".venv",
        auto_detect = true,
        -- Kitty protocol works perfectly with Ghostty terminal
        image_backend = "kitty",
      })
    end,
  },
}
