return {
  "zaldih/themery.nvim",
  lazy = false,
  keys = {
    { "<leader>z", "<cmd>Themery<cr>", desc = "Theme Switcher" },
  },
  config = function()
    require("themery").setup({
      themes = {
        -- Catppuccin variants
        {
          name = "Catppuccin Mocha",
          colorscheme = "catppuccin-mocha",
        },
        {
          name = "Catppuccin Macchiato",
          colorscheme = "catppuccin-macchiato",
        },
        {
          name = "Catppuccin Frappe",
          colorscheme = "catppuccin-frappe",
        },
        {
          name = "Catppuccin Latte",
          colorscheme = "catppuccin-latte",
        },
        -- Tokyo Night variants
        {
          name = "Tokyo Night",
          colorscheme = "tokyonight-night",
        },
        {
          name = "Tokyo Night Storm",
          colorscheme = "tokyonight-storm",
        },
        {
          name = "Tokyo Night Moon",
          colorscheme = "tokyonight-moon",
        },
        {
          name = "Tokyo Night Day",
          colorscheme = "tokyonight-day",
        },
        -- Gruvbox variants
        {
          name = "Gruvbox Dark",
          colorscheme = "gruvbox",
          before = [[vim.o.background = "dark"]],
        },
        {
          name = "Gruvbox Light",
          colorscheme = "gruvbox",
          before = [[vim.o.background = "light"]],
        },
        -- One Dark
        {
          name = "One Dark",
          colorscheme = "onedark",
        },
        -- Rose Pine variants
        {
          name = "Rose Pine",
          colorscheme = "rose-pine-main",
        },
        {
          name = "Rose Pine Moon",
          colorscheme = "rose-pine-moon",
        },
        {
          name = "Rose Pine Dawn",
          colorscheme = "rose-pine-dawn",
        },
        -- GitHub Dark variants
        {
          name = "GitHub Dark",
          colorscheme = "github_dark_default",
        },
        {
          name = "GitHub Dark Dimmed",
          colorscheme = "github_dark_dimmed",
        },
        {
          name = "GitHub Dark High Contrast",
          colorscheme = "github_dark_high_contrast",
        },
        {
          name = "Night Gem",
          colorscheme = "nightgem",
        },
      },
    })
  end,
}
