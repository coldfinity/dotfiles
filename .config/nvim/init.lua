-- Vendored treesitter queries live outside the repo (off git) in the data
-- dir; prepend so they're found first on runtimepath.
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/vendored")

require("core.pack")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lsp")
