require("nvim-treesitter").setup({
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"python",
		"typst",
		"latex",
		"c",
		"cpp",
		"r",
		"html",
		"css",
		"javascript",
		"typescript",
		"bash",
		"json",
		"yaml",
		"markdown",
		"markdown_inline",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- ── treesitter text objects ──────────────────────────────────
-- Native incremental selection (an/in/]n/[n) is built into Nvim and
-- left untouched; this adds *semantic* objects (function/class/param).
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true, -- jump forward to textobj like targets.vim
		selection_modes = {
			["@function.outer"] = "V", -- linewise for functions
		},
	},
	move = { set_jumps = true }, -- record moves in the jumplist
})

local select = require("nvim-treesitter-textobjects.select").select_textobject
local move = require("nvim-treesitter-textobjects.move")

-- select: vaf/vif (function), vac/vic (class), vaa/via (parameter)
local ts_select = {
	af = "@function.outer",
	["if"] = "@function.inner",
	ac = "@class.outer",
	ic = "@class.inner",
	aa = "@parameter.outer",
	ia = "@parameter.inner",
}
for lhs, obj in pairs(ts_select) do
	vim.keymap.set({ "x", "o" }, lhs, function()
		select(obj, "textobjects")
	end, { desc = "Select " .. obj })
end

-- move: ]f/[f & ]c/[c (starts), ]F/[F (function ends); records jumplist
local ts_move = {
	["]f"] = { move.goto_next_start, "@function.outer" },
	["]c"] = { move.goto_next_start, "@class.outer" },
	["[f"] = { move.goto_previous_start, "@function.outer" },
	["[c"] = { move.goto_previous_start, "@class.outer" },
	["]F"] = { move.goto_next_end, "@function.outer" },
	["[F"] = { move.goto_previous_end, "@function.outer" },
}
for lhs, spec in pairs(ts_move) do
	vim.keymap.set({ "n", "x", "o" }, lhs, function()
		spec[1](spec[2], "textobjects")
	end, { desc = "Move " .. spec[2] })
end
