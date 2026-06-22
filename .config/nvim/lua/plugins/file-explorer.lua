local ok, neotree = pcall(require, "neo-tree")
if not ok then
	return
end

neotree.setup({
	close_if_last_window = true,
	enable_git_status = true,
	enable_diagnostics = true,
	-- set width = 30
	--window = { position = "current" },
	--window = { position = "float" },
	window = { position = "left", width = 40 },
	filesystem = {
		filtered_items = { hide_dotfiles = false, hide_gitignored = true },
		follow_current_file = { enabled = true },
	},
})

local ok, oil = pcall(require, "oil")
if not ok then
	return
end

oil.setup({
	-- oil is the netrw replacement; neo-tree stays as the sidebar tree.
	default_file_explorer = true,
	-- reflect external filesystem changes live
	watch_for_changes = true,
	columns = {
		"icon",
		"permissions",
		"size",
	},
	view_options = {
		-- show dotfiles by default; toggle in-buffer with `g.`
		show_hidden = true,
		natural_order = true,
	},
	float = {
		padding = 2,
		max_width = 100,
		max_height = 0,
	},
	use_default_keymaps = true,
	keymaps = {
		["q"] = "actions.close",
		["gp"] = "actions.preview",
	},
})
