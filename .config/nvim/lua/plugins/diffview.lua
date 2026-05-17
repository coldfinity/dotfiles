local ok, diffview = pcall(require, "diffview")
if not ok then return end

diffview.setup()

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo history" })
vim.keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
