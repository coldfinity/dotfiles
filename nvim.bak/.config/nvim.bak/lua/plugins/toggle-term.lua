return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      direction = "float", -- float | vertical | horizontal | tab
      start_in_insert = true,
      persist_size = true,
      float_opts = {
        border = "rounded",
      },
    },
    keys = {
      { "<leader>\\", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical Terminal" },
    },
  },
}
