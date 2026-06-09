local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
	wk.setup({
		preset = "helix",
		delay = 400,
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "harpoon & hunks" },
			{ "<leader>c", group = "code" },
			{ "<leader>s", group = "splits & search" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>d", group = "debug" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader>p", group = "plugins & pdf" },
			{ "<leader>a", group = "claude" },
			{ "<leader>t", group = "todo" },
			{ "<leader>n", group = "docstrings" },
		},
	})
end

local ibl_ok, ibl = pcall(require, "ibl")
if ibl_ok then
	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
	vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
	ibl.setup({
		indent = { char = "│" },
		scope = { enabled = true },
		exclude = { filetypes = { "help", "neo-tree", "dashboard" } },
	})
end
