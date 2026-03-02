return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/Documents/Obsidian",
        },
      },
      completion = {
        nvim_cmp = true,
      },
      new_notes_location = "notes_subdir",
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Note" },
      { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
      { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find Note" },
    },
  },
}
