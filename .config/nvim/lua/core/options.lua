-- ── core/options.lua ─────────────────────────────────────────
local o = vim.opt

-- appearance
o.termguicolors = true
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 8
o.wrap = true
o.linebreak = true -- break at word boundaries, not mid-word
o.showmode = false

-- Cursor
o.guicursor = "" -- block cursor for all modes

-- indentation
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true

-- search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false

-- splits
o.splitbelow = true
o.splitright = true

-- files
o.autoread = true
o.swapfile = false
o.backup = false
o.undofile = true
o.undodir = vim.fn.stdpath("data") .. "/undo"

-- misc
o.updatetime = 200
o.timeoutlen = 300
o.clipboard = "unnamedplus"
o.foldenable = false
o.foldlevel = 99

o.completeopt = "menu,menuone,noselect"
