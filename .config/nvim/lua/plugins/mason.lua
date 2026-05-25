-- Prepend mason's bin dir to PATH so native vim.lsp.config finds installed servers
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local ok, mason = pcall(require, "mason")
if not ok then
	return
end

mason.setup({ ui = { border = "rounded" } })

local ensure_installed = {
	-- LSP servers
	"lua-language-server",
	"pyright",
	"clangd",
	"tinymist",
	"r-languageserver",
	"marksman",
	"html-lsp",
	"css-lsp",
	"typescript-language-server",
	"tailwindcss-language-server",
	"eslint-lsp",
    "ltex-ls",
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
}

local registry = require("mason-registry")
registry.refresh(function()
	for _, name in ipairs(ensure_installed) do
		local ok, pkg = pcall(registry.get_package, name)
		if ok and not pkg:is_installed() then
			pkg:install()
		end
	end
end)
