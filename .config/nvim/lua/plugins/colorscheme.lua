local ok, rosepine = pcall(require, "rose-pine")
if not ok then
	return
end

rosepine.setup({
	variant = "main", -- "main", "moon", or "dawn"
	dark_variant = "main",
	dim_inactive_windows = false,
	extend_background_behind_borders = true,
	styles = {
		bold = true,
		italic = true,
		transparency = true,
	},
})

vim.cmd("colorscheme rose-pine")
