vim.pack.add({
	"https://github.com/coldfinity/tenebris.nvim",
	"https://github.com/oskarnurm/koda.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/thesimonho/kanagawa-paper.nvim",
	"https://github.com/zaldih/themery.nvim",
})

require("tenebris").setup({
	transparent = true,
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
		-- Tenebris Light is the same colorscheme with background = "light".
		-- Each entry sets the background (and tenebris' transparency) itself, so
		-- switching away from the light theme never leaves the next one light.
		-- Light is opaque: its dark text would be unreadable over a dark,
		-- translucent terminal.
		{
			name = "Tenebris",
			colorscheme = "tenebris",
			before = [[ vim.opt.background = "dark"; require("tenebris").setup({ transparent = true }) ]],
		},
		{
			name = "Tenebris Light",
			colorscheme = "tenebris",
			before = [[ vim.opt.background = "light"; require("tenebris").setup({ transparent = false }) ]],
		},
		{ name = "Koda", colorscheme = "koda", before = [[ vim.opt.background = "dark" ]] },
		{ name = "Rose Pine", colorscheme = "rose-pine", before = [[ vim.opt.background = "dark" ]] },
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
