return {
	{
		"jeryldev/pyworks.nvim",
		dependencies = {
			{ "jeryldev/molten-nvim", build = ":UpdateRemotePlugins" },
			{
				"3rd/image.nvim",
				opts = {
					backend = "kitty", -- Ghostty protocol works perfectly
					clear_in_insert_mode = false, -- Prevent hiding while typing
					render_on_move = false, -- Only render when the cursor stops
					render_on_change = true, -- Re-render text changes (needed for editing)
					max_width_window_percentage = 100,
					window_overlap_clear_enabled = true,
					-- Increase the debounce on re-renders while typing
					render_debounce_ms = 500, -- Wait 500ms after text stops changing
				},
			},
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
