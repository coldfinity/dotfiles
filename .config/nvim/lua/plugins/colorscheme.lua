local ok, tenebris = pcall(require, "tenebris")
if not ok then
	return
end

tenebris.setup({
	transparent = true,
	-- italic_comments = false,
	-- bold_keywords   = false,
})

vim.cmd("colorscheme tenebris")
