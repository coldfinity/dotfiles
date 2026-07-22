-- Latex support
return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "open"
      vim.g.vimtex_view_general_options = "-a Preview"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
}
