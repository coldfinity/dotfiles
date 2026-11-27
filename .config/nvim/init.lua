-- Leader must be set before any plugin file registers keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("plugins")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lsp")
require("core.run")
