local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
	wk.setup({
		preset = "helix",
		delay = 400,
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "harpoon & hunks" },
			{ "<leader>c", group = "code" },
			{ "<leader>s", group = "splits & search" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>d", group = "debug" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader>p", group = "plugins & pdf" },
			{ "<leader>a", group = "claude" },
			{ "<leader>t", group = "todo" },
			{ "<leader>n", group = "docstrings" },
		},
	})
end

local ibl_ok, ibl = pcall(require, "ibl")
if ibl_ok then
	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
	vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
	ibl.setup({
		indent = { char = "│" },
		scope = { enabled = true },
		exclude = { filetypes = { "help", "neo-tree", "dashboard" } },
	})
end

local lualine_ok, lualine = pcall(require, "lualine")
if lualine_ok then
	lualine.setup({
		options = {
			theme = "auto",
			globalstatus = true,
			component_separators = { left = "|", right = "|" },
			section_separators = { left = "|", right = "|" },
		},
		sections = {
			lualine_a = {
				{ "mode", icons_enabled = true },
			},
			lualine_b = {
				{ "branch", icon = "" },
				"diff",
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
				},
			},
			lualine_c = {
				{
					"filename",
					path = 1,
					symbols = { modified = "", readonly = "", unnamed = "[No Name]" },
				},
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
			lualine_x = {
				"fileformat",
				"filetype",
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
end

local bufferline_ok, bufferline = pcall(require, "bufferline")
if bufferline_ok then
	bufferline.setup({
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
end
