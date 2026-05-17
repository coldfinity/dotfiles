local pairs_ok, pairs = pcall(require, "mini.pairs")
if pairs_ok then pairs.setup() end

local surround_ok, surround = pcall(require, "mini.surround")
if surround_ok then
	surround.setup({
		mappings = {
			add = "gza",
			delete = "gzd",
			replace = "gzr",
			find = "gzf",
			find_left = "gzF",
			highlight = "gzh",
			update_n_lines = "gzn",
		},
	})
end

local comment_ok, comment = pcall(require, "mini.comment")
if comment_ok then comment.setup() end
