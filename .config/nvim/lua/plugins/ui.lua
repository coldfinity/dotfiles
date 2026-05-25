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
	local highlight = {
		"RainbowRed",
		"RainbowYellow",
		"RainbowBlue",
		"RainbowOrange",
		"RainbowGreen",
		"RainbowViolet",
		"RainbowCyan",
	}

	local hooks = require("ibl.hooks")
	hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
		vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
		vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
		vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
		vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
		vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
		vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
		vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
	end)

	ibl.setup({
		indent = { char = "│", highlight = highlight },
		scope = { enabled = true },
		exclude = { filetypes = { "help", "neo-tree", "dashboard" } },
	})
end
