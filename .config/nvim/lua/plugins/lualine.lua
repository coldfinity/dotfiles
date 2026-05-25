local ok, lualine = pcall(require, "lualine")
if not ok then
	return
end

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
			{ "branch", icon = "" },
			"diff",
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
			},
		},
		lualine_c = {
			{
				"filename",
				path = 1,
				symbols = { modified = "", readonly = "", unnamed = "[No Name]" },
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
					return " " .. table.concat(names, ", ")
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
