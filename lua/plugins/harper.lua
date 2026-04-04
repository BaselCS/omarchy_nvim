return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				harper_ls = {
					filetypes = { "markdown", "gitcommit", "python", "dart" },
					settings = {
						["harper-ls"] = {
							diagnosticSeverity = "hint",
							markdown = {
								IgnoreLinkTitle = true,
							},
							linters = {
								SpellCheck = true,
								show_lsp_diagnostics_in_hover_window = true,
								SpelledNumbers = false,
								AnA = true,
								UnclosedQuotes = true,
								LongSentences = false,
								SentenceCapitalization = true,
								RepeatedWords = true,
								CorrectNumberSuffix = true,
								CapitalizePersonalPronouns = true,
								BoringWords = true,
							},
						},
					},
				},
			},
			setup = {
				harper_ls = function(server, server_opts)
					-- Register the server config but do not auto-enable it.
					vim.lsp.config(server, server_opts)
					return true
				end,
			},
		},
	},

	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = { "harper-ls" },
		},
	},
}
