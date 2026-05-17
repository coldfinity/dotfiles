return {
  -- copilot
  "github/copilot.vim",

  -- cmp
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsth7th/cmp-buffer",
    "hrsth7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- loads vscode style snippits from installed plugins
    require("luasnip.loaders.from_vscode").lazyload()

    cmp.setup({
      enable = true,
      preselect = cmp.PreselectMode.None, -- do not preselect any item

      completion = {
        completeopt = "menu,menuone,preview, noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippit engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "nvim_lsp" },
      }),
    })
  end,
}
