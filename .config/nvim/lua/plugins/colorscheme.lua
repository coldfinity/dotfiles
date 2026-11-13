vim.pack.add({
	"https://github.com/coldfinity/tenebris.nvim",
	"https://github.com/oskarnurm/koda.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/thesimonho/kanagawa-paper.nvim",
	"https://github.com/zaldih/themery.nvim",
})

require("tenebris").setup({
	transparent = true,
	-- italic_comments = false,
	-- bold_keywords   = false,
})

require("koda").setup({
	transparent = true,
	theme = {
		dark = "dark",
	},
})

require("rose-pine").setup({
	styles = {
		transparency = true,
		italic = false,
		bold = false,
	},
})

require("kanagawa-paper").setup({
	transparent = true,
})

-- ── themery.nvim ──────────────────────────────────────────────
-- Theme picker with live preview and persistence.
-- Run :Themery to switch. Picked theme persists across sessions.
-- ───────────────────────────────────────────────────────────────
local themery = require("themery")
themery.setup({
	themes = {
		{ name = "Tenebris", colorscheme = "tenebris" },
		{ name = "Koda", colorscheme = "koda" },
		{ name = "Rose Pine", colorscheme = "rose-pine" },
		{
			name = "Kanagawa Paper (Ink)",
			colorscheme = "kanagawa-paper-ink",
			before = [[ vim.opt.background = "dark" ]],
		},
	},
	livePreview = true,
})
-- Fallback: only apply tenebris if nothing was persisted yet
if themery.getCurrentTheme() == nil then
	vim.cmd("colorscheme tenebris")
end

require("core.map")("n", "<leader>T", "<cmd>Themery<cr>", "Theme picker")
