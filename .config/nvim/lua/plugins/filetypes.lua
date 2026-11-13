-- Language-specific plugins.

-- ── vimtex (LaTeX) ───────────────────────────────────────────
-- Compile with latexmk, view in zathura (forward/inverse search).
-- Must be configured before the plugin loads.
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 0 -- don't auto-open quickfix on warnings

vim.pack.add({ "https://github.com/lervag/vimtex" })

-- Commands (buffer-local in tex files): :VimtexCompile, :VimtexView,
-- :VimtexTocToggle, :VimtexClean, :VimtexInfo. Mappings start with <localleader>l.
