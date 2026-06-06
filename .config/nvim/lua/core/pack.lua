-- ── core/pack.lua ────────────────────────────────────────────
-- Uses vim.pack, the built-in plugin manager added in Nvim 0.12.
-- Run :lua vim.pack.update() to update all plugins.
-- ─────────────────────────────────────────────────────────────

vim.pack.add({
	-- colorschemes
	"https://github.com/coldfinity/tenebris.nvim",
	"https://github.com/oskarnurm/koda.nvim",
	"https://github.com/rose-pine/neovim",

	-- treesitter (better syntax highlighting)
	"https://github.com/nvim-treesitter/nvim-treesitter",

	-- waypoint todos
	"https://github.com/coldfinity/waypoint.nvim",

	-- claude code
	"https://github.com/coder/claudecode.nvim",

	-- auto close html/jsx tags
	"https://github.com/windwp/nvim-ts-autotag",

	-- harpoon
	"https://github.com/ThePrimeagen/harpoon",

	-- fuzzy finder
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",

	-- file tree
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/MunifTanjim/nui.nvim",

	-- git
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/sindrets/diffview.nvim",

	-- statusline
	"https://github.com/nvim-lualine/lualine.nvim",

	-- editing (mini.nvim replaces autopairs, surround, comment)
	"https://github.com/echasnovski/mini.nvim",

	-- navigation
	"https://github.com/folke/flash.nvim",

	-- undo history
	"https://github.com/mbbill/undotree",

	-- diagnostics & quickfix
	"https://github.com/folke/trouble.nvim",

	-- terminal
	"https://github.com/akinsho/toggleterm.nvim",

	-- project-wide search & replace
	"https://github.com/MagicDuck/grug-far.nvim",

	-- lsp server management
	"https://github.com/williamboman/mason.nvim",

	-- debugging
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mfussenegger/nvim-dap-python",

	-- ui
	"https://github.com/folke/which-key.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/nvimdev/dashboard-nvim",
	"https://github.com/rcarriga/nvim-notify",
	"https://github.com/folke/noice.nvim",

	-- formatting
	"https://github.com/stevearc/conform.nvim",

	-- docstring/annotation generation
	"https://github.com/danymat/neogen",

	-- smear cursor
	"https://github.com/sphamba/smear-cursor.nvim",

	-- completions
	"https://github.com/saghen/blink.lib",
	"https://github.com/Saghen/blink.cmp",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
})

-- Load all plugin config files alphabetically.
-- mason.lua prepends its bin dir to PATH instantly (line 1), so
-- PATH is available before core/lsp.lua runs, regardless of order.
for name, type in vim.fs.dir(vim.fn.stdpath("config") .. "/lua/plugins") do
	if type == "file" and name:match("%.lua$") then
		require("plugins." .. name:gsub("%.lua$", ""))
	end
end
