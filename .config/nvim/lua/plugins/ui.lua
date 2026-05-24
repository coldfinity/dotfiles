local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
	wk.setup({
		delay = 400,
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "hunks" },
			{ "<leader>c", group = "code" },
			{ "<leader>s", group = "splits & search" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>d", group = "debug" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader>p", group = "plugins & pdf" },
			{ "<leader>a", group = "claude" },
		},
	})
end

local ibl_ok, ibl = pcall(require, "ibl")
if ibl_ok then
	ibl.setup({
		indent = { char = "│" },
		scope = { enabled = true },
		exclude = { filetypes = { "help", "neo-tree" } },
	})
end
