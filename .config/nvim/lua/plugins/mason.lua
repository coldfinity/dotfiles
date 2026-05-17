-- Prepend mason's bin dir to PATH so native vim.lsp.config finds installed servers
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local ok, mason = pcall(require, "mason")
if not ok then
	return
end

mason.setup({
	ui = { border = "rounded" },
	ensure_installed = {
		-- LSP servers
		"lua-language-server",
		"pyright",
		"clangd",
		"tinymist",
		"r-languageserver",
		-- Debug adapters
		"debugpy",
		"codelldb",
		-- Formatters
		"stylua",
		"black",
		"isort",
		"clang-format",
		"prettier",
		"typstyle",
	},
})
