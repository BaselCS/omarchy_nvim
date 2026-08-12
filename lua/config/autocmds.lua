local function highlight_yank()
	if vim.fn.has("nvim-0.13") == 1 and vim.hl.hl_op then
		vim.hl.hl_op()
	else
		(vim.hl or vim.highlight).on_yank()
	end
end

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("lazyvim_highlight_yank", { clear = true }),
	callback = highlight_yank,
})
