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
      require("github-theme").setup({
        trasparent = true, -- enable transparent background
        darken = {
          floats = true, -- darken floating windows
          sidebars = {
            enabled = true, -- darken sidebars
            list = {}, -- darken list windows
          },
        },
        styles = {
          comments = "italic", -- italic comments
          keywords = "bold", -- italic keywords
          types = "italic, bold",
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
