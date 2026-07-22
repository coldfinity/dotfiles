local ok, tenebris = pcall(require, "tenebris")
if not ok then
	return
end

tenebris.setup({
	transparent = true,
	-- italic_comments = false,
	-- bold_keywords   = false,
})

local koda_ok, koda = pcall(require, "koda")
if koda_ok then
	koda.setup({
		transparent = true,
		theme = {
			dark = "dark",
		},
	})
end

local rose_ok, rose_pine = pcall(require, "rose-pine")
if rose_ok then
	rose_pine.setup({
		styles = {
			transparency = true,
			italic = false,
			bold = false,
		},
	})
end

local kp_ok, kanagawa_paper = pcall(require, "kanagawa-paper")
if kp_ok then
	kanagawa_paper.setup({
		transparent = true,
	})
end

-- ── themery.nvim ──────────────────────────────────────────────
-- Theme picker with live preview and persistence.
-- Run :Themery to switch. Picked theme persists across sessions.
-- ───────────────────────────────────────────────────────────────
local themery_ok, themery = pcall(require, "themery")
if themery_ok then
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
else
	-- themery not installed — just use tenebris directly
	vim.cmd("colorscheme tenebris")
end
