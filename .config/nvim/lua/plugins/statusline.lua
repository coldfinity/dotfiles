vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/akinsho/bufferline.nvim",
})

local lualine = require("lualine")
local tmux_session = ""

if vim.env.TMUX and vim.fn.executable("tmux") == 1 then
	local function refresh_tmux_session()
		local cmd = { "tmux", "display-message", "-p" }
		if vim.env.TMUX_PANE then
			vim.list_extend(cmd, { "-t", vim.env.TMUX_PANE })
		end
		table.insert(cmd, "#S")
		vim.system(
			cmd,
			{ text = true, timeout = 1000 },
			vim.schedule_wrap(function(result)
				tmux_session = result.code == 0 and vim.trim(result.stdout) or ""
				lualine.refresh({ place = { "statusline" } })
			end)
		)
	end

	vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
		group = vim.api.nvim_create_augroup("lualine_tmux_session", { clear = true }),
		callback = refresh_tmux_session,
	})
	refresh_tmux_session()
end

lualine.setup({
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
					return tmux_session
				end,
				cond = function()
					return tmux_session ~= ""
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
		close_command = "bdelete %d",
		left_mouse_command = "buffer %d",
		middle_mouse_command = "bdelete %d",
		right_mouse_command = "vertical sbuffer %d",
	},
})
