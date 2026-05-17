return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "lua_ls",
      "rust_analyzer",
      "pyright",
      "clangd",
      "stylua",
      "cmake",
      "html",
      "cssls",
      "ts_ls",
      "tinymist",
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
