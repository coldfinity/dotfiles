local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		r = { "styler" },
		typst = { "typstyle" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		typescript = { "prettier" },
	},
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
})
