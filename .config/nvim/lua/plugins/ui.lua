vim.pack.add({
	"https://github.com/folke/which-key.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/nvimdev/dashboard-nvim",
	"https://github.com/rcarriga/nvim-notify",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/folke/noice.nvim",
	"https://github.com/sphamba/smear-cursor.nvim",
})

-- ── which-key ────────────────────────────────────────────────
require("which-key").setup({
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

-- ── indent guides ────────────────────────────────────────────
require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = true },
	exclude = { filetypes = { "help", "neo-tree", "dashboard" } },
})

-- ── markview ─────────────────────────────────────────────────
require("markview").setup({
	preview = {
		filetypes = { "markdown" },
	},
})

-- ── dashboard ────────────────────────────────────────────────
require("dashboard").setup({
	theme = "hyper",
	config = {
		week_header = { enable = true },
		shortcut = {
			{ desc = "Update plugins", group = "@property", action = "lua vim.pack.update()", key = "u" },
			{ desc = "Find file", group = "Label", action = "Telescope find_files", key = "f" },
			{ desc = "Live grep", group = "DiagnosticHint", action = "Telescope live_grep", key = "g" },
			{ desc = "Recent files", group = "Number", action = "Telescope oldfiles", key = "r" },
			{ desc = "Config", group = "String", action = "Telescope find_files cwd=~/.config/nvim", key = "c" },
		},
		packages = { enable = true },
		project = {
			enable = false,
			limit = 8,
			icon = " ",
			label = " Recent projects:",
			action = "Telescope find_files cwd=",
		},
		mru = { enable = true, limit = 15, icon = " ", label = " Recent files:", cwd_only = true },
		footer = {},
	},
})

-- ── notify & noice ───────────────────────────────────────────
require("notify").setup({
	background_colour = "#000000",
})

require("noice").setup({
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

-- ── smear cursor ─────────────────────────────────────────────
require("smear_cursor").setup({
	stiffness = 0.8,
	trailing_stiffness = 0.5,
	distance_stop_animating = 0.5,
	hide_target_hack = false,
})
