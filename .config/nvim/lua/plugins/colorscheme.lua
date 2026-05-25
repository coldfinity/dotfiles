local ok, tenebris = pcall(require, "tenebris")
if not ok then
	return
end

tenebris.setup({
	transparent = true,
	-- italic_comments = false,
	-- bold_keywords   = false,
})

local koda_ok, koda = pcall(require, "koda")
if koda_ok then
	koda.setup({
		transparent = true,
		theme = {
			dark = "dark",
		},
	})
end

local rose_ok, rose_pine = pcall(require, "rose-pine")
if rose_ok then
	rose_pine.setup({
		styles = {
			transparency = true,
		},
	})
end

vim.cmd("colorscheme tenebris")
--vim.cmd("colorscheme koda")
--vim.cmd("colorscheme rose-pine")
