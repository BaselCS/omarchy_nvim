return {
	{
		"saghen/blink.cmp",
		opts = {
			signature = { enabled = true },
			keymap = {
				["<CR>"] = {
					LazyVim.cmp.map({ "ai_accept" }),
					"accept",
					"fallback",
				},
			},
		},
	},
}
