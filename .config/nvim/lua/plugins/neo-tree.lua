local ok, neotree = pcall(require, "neo-tree")
if not ok then
	return
end

neotree.setup({
	close_if_last_window = true,
	enable_git_status = true,
	enable_diagnostics = true,
	-- set width = 30
	--window = { position = "current"},
	--window = { position = "float" },
	window = { position = "left", width = 30 },
	filesystem = {
		filtered_items = { hide_dotfiles = false, hide_gitignored = true },
		follow_current_file = { enabled = true },
	},
})
