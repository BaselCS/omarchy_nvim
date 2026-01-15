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
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "harper-ls")
    end,
  },
}
