return {
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      -- pyright will be automatically installed with mason and loaded with lspconfig
      pyright = {},
      clangd = {},
    },
    ensure_installed = {
      "pyright",
      "clangd",
      "stylua",
      "cmake",
      "markdown-oxide",
      "r-langaugeserver",
      "copilot-language-server",
    },
  },
}
