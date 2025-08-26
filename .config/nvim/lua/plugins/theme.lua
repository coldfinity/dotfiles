return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    -- you can do it like this with a config function
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        -- configurations
      })
    end,
    -- or just use opts table
    opts = {
      -- configurations
    },
  },

  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local transparent = true
      require("github-theme").setup({
        options = {
          transparent = transparent,
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
            sidebars = transparent and "transparent" or "dark",
            floats = transparent and "transparent" or "dark",
          },
        },
      })
      vim.cmd("colorscheme github_dark")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_dark_default", -- set your colorscheme here
    },
  },
}
