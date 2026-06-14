require("nvim-treesitter").setup({
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"python",
		"typst",
		"latex",
		"c",
		"cpp",
		"r",
		"html",
		"css",
		"javascript",
		"typescript",
		"bash",
		"json",
		"yaml",
		"markdown",
		"markdown_inline",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
