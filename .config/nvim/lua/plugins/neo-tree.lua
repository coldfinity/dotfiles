local ok, neotree = pcall(require, "neo-tree")
if not ok then
	return
end

neotree.setup({
	close_if_last_window = true,
	window = { position = "current", width = 30 },
	filesystem = {
		filtered_items = { hide_dotfiles = false, hide_gitignored = true },
		follow_current_file = { enabled = true },
	},
})
