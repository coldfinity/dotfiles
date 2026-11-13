vim.pack.add({
	"https://github.com/folke/trouble.nvim",
	"https://github.com/coldfinity/waypoint.nvim",
})

require("trouble").setup()
require("waypoint").setup({ keymap = false })

local map = require("core.map")

-- trouble (diagnostics & lists)
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (project)")
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Diagnostics (buffer)")
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Location list")
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix list")

-- waypoint (todos)
map("n", "<leader>td", function()
	require("waypoint").open()
end, "Todo list")
