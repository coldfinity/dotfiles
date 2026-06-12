local ok, bufferline = pcall(require, "bufferline")
if not ok then
	return
end

bufferline.setup({
	options = {
		mode = "buffers",
		themable = true,
		numbers = "none",
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer",
				text_align = "center",
				separator = true,
			},
		},
		hover = {
			enabled = true,
			delay = 200,
			reveal = { "close" },
		},
		separator_style = "thin",
		always_show_bufferline = true,
		enforce_regular_tabs = false,
		show_close_icon = true,
		show_buffer_close_icons = true,
		close_command = "bdelete! %d",
		left_mouse_command = "buffer %d",
		middle_mouse_command = "bdelete! %d",
		right_mouse_command = "vertical sbuffer %d",
	},
})
