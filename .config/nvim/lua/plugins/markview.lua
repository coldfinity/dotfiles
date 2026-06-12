local ok, mv = pcall(require, "markview")
if not ok then
	return
end

mv.setup({
	preview = {
		filetypes = { "markdown" },
	},
})
