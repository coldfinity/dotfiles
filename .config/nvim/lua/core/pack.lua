-- ── core/pack.lua ────────────────────────────────────────────
-- Uses vim.pack, the built-in plugin manager added in Nvim 0.12.
-- Run :lua vim.pack.update() to update all plugins.
-- ─────────────────────────────────────────────────────────────

vim.pack.add({
	-- colorscheme
	"https://github.com/rose-pine/neovim",

	-- treesitter (better syntax highlighting)
	"https://github.com/nvim-treesitter/nvim-treesitter",

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
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	-- "https://github.com/rcarriga/nvim-notify",
	-- "https://github.com/folke/noice.nvim",

	-- formatting
	"https://github.com/stevearc/conform.nvim",

	-- smear cursor
	"https://github.com/sphamba/smear-cursor.nvim",

	-- completions
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/hrsh7th/cmp-cmdline",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/onsails/lspkind.nvim",
})

-- mason must load before lsp so its bin dir is on PATH
require("plugins.mason")

-- core
require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.neo-tree")
require("plugins.git")
require("plugins.diffview")
require("plugins.lualine")
require("plugins.editing")
require("plugins.flash")
require("plugins.trouble")
require("plugins.toggleterm")
require("plugins.grug-far")
require("plugins.ui")
require("plugins.format")
require("plugins.smear-cursor")
require("plugins.completion")
require("plugins.dap")
require("plugins.render-markdown")
-- require("plugins.noice")
