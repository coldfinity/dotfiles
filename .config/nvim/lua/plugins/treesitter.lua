local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

configs.setup({
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
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})
