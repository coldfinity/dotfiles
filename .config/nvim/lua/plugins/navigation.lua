vim.pack.add({
	-- fuzzy finder
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	-- file explorer
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/stevearc/oil.nvim",
	-- jumping
	"https://github.com/folke/flash.nvim",
	"https://github.com/ThePrimeagen/harpoon",
})

local map = require("core.map")

-- ── telescope ────────────────────────────────────────────────
local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
	defaults = {
		prompt_prefix = "   ",
		selection_caret = " ",
		sorting_strategy = "ascending",
		layout_config = {
			horizontal = { prompt_position = "bottom", preview_width = 0.55 },
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

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")

-- ── oil ──────────────────────────────────────────────────────
local oil = require("oil")
oil.setup({
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
	use_default_keymaps = true,
	keymaps = {
		["q"] = "actions.close",
		["gp"] = "actions.preview",
	},
})

local function toggle_oil()
	if vim.bo.filetype == "oil" then
		oil.close()
	else
		oil.open()
	end
end

map("n", "-", "<cmd>Oil<cr>", "Open parent dir (oil)")
map("n", "<leader>e", toggle_oil, "Toggle Oil")
map("n", "<leader>-", toggle_oil, "Toggle Oil")
map("n", "<leader>E", function()
	oil.open(vim.fn.getcwd())
end, "Open working directory in Oil")

-- ── flash ────────────────────────────────────────────────────
require("flash").setup()
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { silent = true, desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { silent = true, desc = "Flash treesitter" })

-- ── harpoon ──────────────────────────────────────────────────
require("harpoon").setup()
map("n", "<leader>ha", function()
	require("harpoon.mark").add_file()
end, "Harpoon add file")
map("n", "<leader>hh", function()
	require("harpoon.ui").toggle_quick_menu()
end, "Harpoon menu")
for i = 1, 4 do
	map("n", "<leader>h" .. i, function()
		require("harpoon.ui").nav_file(i)
	end, "Harpoon file " .. i)
end
