local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
	return
end

gitsigns.setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(buf)
		local gs = package.loaded.gitsigns
		local map = function(l, r, desc)
			vim.keymap.set("n", l, r, { buffer = buf, desc = desc })
		end
		map("]h", gs.next_hunk, "Next hunk")
		map("[h", gs.prev_hunk, "Prev hunk")
		map("<leader>hs", gs.stage_hunk, "Stage hunk")
		map("<leader>hr", gs.reset_hunk, "Reset hunk")
		map("<leader>hp", gs.preview_hunk, "Preview hunk")
		map("<leader>hb", function()
			gs.blame_line({ full = true })
		end, "Blame line")
	end,
})
