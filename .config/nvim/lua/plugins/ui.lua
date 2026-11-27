vim.pack.add({
	"https://github.com/folke/which-key.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
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
	exclude = { filetypes = { "help", "oil" } },
})

-- ── markview ─────────────────────────────────────────────────
require("markview").setup({
	preview = {
		filetypes = { "markdown" },
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
