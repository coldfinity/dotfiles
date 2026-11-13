vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/akinsho/bufferline.nvim",
})

require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = true,
		globalstatus = true,
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "|", right = "|" },
	},
	sections = {
		lualine_a = {
			"mode",
		},
		lualine_b = {
			"branch",
			"diff",
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
			},
		},
		lualine_c = {
			{
				function()
					return vim.fn.system({ "tmux", "display-message", "-p", "#S" }):gsub("%s+$", "")
				end,
				cond = function()
					return vim.env.TMUX ~= nil
				end,
				icon = "",
			},
			{
				"filename",
				path = 1,
			},
		},
		lualine_x = {
			--"fileformat",
			"filetype",
			{
				function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients == 0 then
						return ""
					end
					local names = {}
					for _, c in ipairs(clients) do
						table.insert(names, c.name)
					end
					return " " .. table.concat(names, ", ")
				end,
			},
		},
		lualine_y = {
			"progress",
		},
		lualine_z = {
			"location",
		},
	},
	inactive_sections = {
		lualine_a = { "filename" },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { "location" },
	},
})
require("bufferline").setup({
	options = {
		mode = "buffers",
		themable = true,
		numbers = "none",
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
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