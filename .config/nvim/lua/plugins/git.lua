vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/sindrets/diffview.nvim",
})

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
})

require("diffview").setup()

local map = require("core.map")

-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit")

-- gitsigns hunks
map("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end, "Next hunk")
map("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end, "Prev hunk")
map("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, "Stage hunk")
map("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, "Reset hunk")
map("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, "Preview hunk")
map("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, "Blame line")

-- diffview
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diff view")
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", "File history")
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", "Repo history")
map("n", "<leader>gx", "<cmd>DiffviewClose<cr>", "Close diffview")
