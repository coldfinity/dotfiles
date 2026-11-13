vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/mbbill/undotree",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/danymat/neogen",
	"https://github.com/akinsho/toggleterm.nvim",
})

local map = require("core.map")

-- ── mini.nvim (pairs, surround, comment) ─────────────────────
require("mini.pairs").setup({ mappings = { ["<CR>"] = false } })
require("mini.surround").setup({
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
require("mini.comment").setup()

-- ── undotree ─────────────────────────────────────────────────
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", "Toggle undo tree")

-- ── grug-far (project search & replace) ──────────────────────
require("grug-far").setup()
map("n", "<leader>sr", function()
	require("grug-far").open()
end, "Search & replace (project)")
map("v", "<leader>sr", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, "Search & replace (word)")
map("n", "<leader>sf", function()
	require("grug-far").open({ paths = vim.fn.expand("%") })
end, "Search & replace (current file)")

-- ── neogen (docstrings) ──────────────────────────────────────
require("neogen").setup({
	enabled = true,
	snippet_engine = "luasnip",
	languages = {
		python = {
			template = {
				annotation_convention = "google_docstrings",
			},
		},
	},
})
map("n", "<leader>nf", function()
	require("neogen").generate({ type = "func" })
end, "Neogen function docstring")
map("n", "<leader>nc", function()
	require("neogen").generate({ type = "class" })
end, "Neogen class docstring")
map("n", "<leader>nt", function()
	require("neogen").generate({ type = "type" })
end, "Neogen type docstring")

-- ── toggleterm ───────────────────────────────────────────────
require("toggleterm").setup({
	direction = "float",
	float_opts = { border = "rounded" },
})
map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", "Toggle terminal")
map("t", "<C-\\>", "<cmd>ToggleTerm<cr>", "Toggle terminal")
