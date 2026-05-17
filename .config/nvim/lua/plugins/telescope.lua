local ok, telescope = pcall(require, "telescope")
if not ok then
	return
end
local actions = require("telescope.actions")

telescope.setup({
	defaults = {
		prompt_prefix = "   ",
		selection_caret = " ",
		sorting_strategy = "ascending",
		layout_config = {
			horizontal = { prompt_position = "top", preview_width = 0.55 },
		},
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<esc>"] = actions.close,
			},
		},
		file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/" },
	},
	pickers = {
		find_files = { hidden = true },
		buffers = { sort_mru = true },
	},
})

pcall(telescope.load_extension, "fzf")
