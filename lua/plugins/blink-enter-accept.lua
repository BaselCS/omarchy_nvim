return {
	{
		"saghen/blink.cmp",
		opts = {
			signature = { enabled = true },
			keymap = {
				["<CR>"] = {
					"accept",
					LazyVim.cmp.map({ "ai_accept" }),
					"fallback",
				},
			},
		},
	},
}
