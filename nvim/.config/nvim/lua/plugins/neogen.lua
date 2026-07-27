local ok, neogen = pcall(require, "neogen")
if not ok then
	return
end

neogen.setup({
	enabled = true,
	snippet_engine = "luasnip",
	languages = {
		python = {
			template = {
				annotation_convention = "google_docstrings",
			},
		},
	},
})
