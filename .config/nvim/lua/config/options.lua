-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
opts = function(_, opts)
  opts.highlight = opts.highlight or {}
  if type(opts.ensure_installed) == "table" then
    vim.list_extend(opts.ensure_installed, { "bibtex" })
  end
  if type(opts.highlight.disable) == "table" then
    vim.list_extend(opts.highlight.disable, { "latex" })
  else
    opts.highlight.disable = { "latex" }
  end
end
