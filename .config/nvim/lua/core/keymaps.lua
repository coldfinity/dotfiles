-- ── core/keymaps.lua ─────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- escape
map("i", "jk", "<esc>")

-- save / quit
map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")
map("n", "<leader>Q", "<cmd>qa!<cr>", "Quit all")

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
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<leader>sv", "<cmd>vsplit<cr>", "Split vertical")
map("n", "<leader>sh", "<cmd>split<cr>", "Split horizontal")

-- buffers
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")

-- file tree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", "Toggle file tree")
map("n", "<leader>E", "<cmd>Neotree reveal<cr>", "Reveal in tree")

-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit")

-- plugin manager
map("n", "<leader>pu", "<cmd>lua vim.pack.update()<cr>", "Update plugins")

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
map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

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
