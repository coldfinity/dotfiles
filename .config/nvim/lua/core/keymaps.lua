-- ── core/keymaps.lua ─────────────────────────────────────────
-- Global/editor keymaps only. Plugin keymaps live in the matching
-- lua/plugins/*.lua file, next to the plugin they belong to.
-- (mapleader is set in init.lua.)
-- ─────────────────────────────────────────────────────────────
local map = require("core.map")

-- escape
map("i", "jk", "<esc>")

-- center on scroll
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- move lines in visual
map("v", "J", ":m '>+1<cr>gv=gv")
map("v", "K", ":m '<-2<cr>gv=gv")

-- paste without yanking
map("x", "<leader>p", '"_dP', "Paste without yanking")

-- splits
-- move in buffers
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
-- move in claude code
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")
-- split buffers
map("n", "<leader>sv", "<cmd>2ToggleTerm direction=vertical size=80<cr>", "Terminal (vertical split)")
map("n", "<leader>sh", "<cmd>1ToggleTerm direction=horizontal size=15<cr>", "Terminal (horizontal split)")

-- buffers
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")

-- plugin manager
map("n", "<leader>pu", "<cmd>lua vim.pack.update()<cr>", "Update plugins")
map("n", "<leader>pr", "<cmd>restart<cr>", "Restart Neovim")

-- open PDF in zathura
map("n", "<leader>pz", function()
	local pdf = vim.fn.expand("%:r") .. ".pdf"
	if vim.fn.filereadable(pdf) == 1 then
		vim.fn.jobstart({ "zathura", pdf }, { detach = true })
	else
		vim.notify("No PDF found: " .. pdf, vim.log.levels.WARN)
	end
end, "Open PDF in Zathura")

-- diagnostics
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Prev diagnostic")
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")
map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
map("n", "<leader>xc", function()
	local win = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		vim.api.nvim_win_close(win, false)
	end
end, "Close diagnostics float")
map("n", "<leader>xy", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics > 0 then
		vim.fn.setreg("+", diagnostics[1].message)
		print("Copied: " .. diagnostics[1].message)
	end
end, "Copy diagnostic on line")

-- NOTE: LSP keymaps (gra, grn, grr, gri, grt, gO, K) are built-in in 0.12
-- Override only what you want to change:
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local map_lsp = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
		end
		map_lsp("gd", vim.lsp.buf.definition, "Go to definition")
		map_lsp("gD", vim.lsp.buf.declaration, "Go to declaration")
		map_lsp("<leader>cf", function()
			vim.lsp.buf.format({ async = true })
		end, "Format")
	end,
})
