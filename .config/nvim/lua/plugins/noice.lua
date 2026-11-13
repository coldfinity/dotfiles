local ok, noice = pcall(require, "noice")
if not ok then
	return
end

noice.setup({
	cmdline = { view = "cmdline" },
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true,
		long_message_to_split = true,
	},
})
