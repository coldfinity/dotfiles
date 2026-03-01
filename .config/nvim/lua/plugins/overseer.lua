return {
  {
    "stevearc/overseer.nvim",
    opts = {
      strategy = "toggleterm", -- uses your toggleterm
      templates = { "builtin" },
    },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run Task" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle Tasks" },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      local overseer = require("overseer")

      -- Python
      overseer.register_template({
        name = "Run Python File",
        builder = function()
          return {
            cmd = { "python3" },
            args = { vim.fn.expand("%") },
            components = { "default" },
          }
        end,
        condition = { filetype = { "python" } },
      })

      -- C++
      overseer.register_template({
        name = "Build & Run C++",
        builder = function()
          local file = vim.fn.expand("%")
          return {
            cmd = { "bash" },
            args = {
              "-c",
              "g++ " .. file .. " -std=c++17 -O2 -Wall -o main && ./main",
            },
            components = { "default" },
          }
        end,
        condition = { filetype = { "cpp" } },
      })

      -- R
      overseer.register_template({
        name = "Run R Script",
        builder = function()
          return {
            cmd = { "Rscript" },
            args = { vim.fn.expand("%") },
            components = { "default" },
          }
        end,
        condition = { filetype = { "r" } },
      })
    end,
  },
}
