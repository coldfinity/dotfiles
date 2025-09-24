return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
        "cpp",
        "latex",
        "java",
        "vim",
        "python",
        "lua",
        "html",
        "css",
        "json",
        "bash",
        "markdown",
        "markdown_inline",
        "javascript",
        "r",
        "csv",
      })
      opts.highlights = { enable = true }
    end,
  },
}
