local ok, db = pcall(require, "dashboard")
if not ok then
	return
end

db.setup({
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
			enable = true,
			limit = 8,
			icon = " ",
			label = " Recent projects:",
			action = "Telescope find_files cwd=",
		},
		mru = { enable = true, limit = 10, icon = " ", label = " Recent files:", cwd_only = true },
		footer = {},
	},
})
