local ok, blink = pcall(require, "blink.cmp")
if not ok then
	return
end

blink.setup({
	fuzzy = { implementation = "prefer_rust" },
	keymap = {
		["<C-space>"] = { "show", "fallback" },
		["<C-e>"] = { "hide", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
	},
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "path", "buffer", "snippets" },
	},
	completion = {
		trigger = {
			show_on_keyword = true,
			show_on_trigger_character = true,
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = { border = "rounded" },
		},
		menu = {
			auto_show = true,
			border = "rounded",
		},
		ghost_text = { enabled = false },
		accept = { auto_brackets = { enabled = true } },
	},
	cmdline = {
		enabled = true,
		keymap = { preset = "cmdline" },
		completion = { menu = { auto_show = true } },
	},
	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},
})

require("luasnip.loaders.from_vscode").lazy_load()
