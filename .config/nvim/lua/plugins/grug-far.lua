local ok, grug = pcall(require, "grug-far")
if not ok then return end

grug.setup()

vim.keymap.set("n", "<leader>sr", function() grug.open() end, { desc = "Search & replace (project)" })
vim.keymap.set("v", "<leader>sr", function()
	grug.open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search & replace (word)" })
