-- ── core/lsp.lua ─────────────────────────────────────────────
-- Uses the native vim.lsp.config / vim.lsp.enable API from Nvim 0.12.
-- Servers are installed via mason (:Mason).
-- ─────────────────────────────────────────────────────────────

-- diagnostics
vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { prefix = "●" },
	float = { border = "rounded", source = "always" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

-- ── Lua ──────────────────────────────────────────────────────
vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
}
vim.lsp.enable("lua_ls")

-- ── Python ───────────────────────────────────────────────────
vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		python = {
			analysis = { typeCheckingMode = "basic", autoSearchPaths = true },
		},
	},
}
vim.lsp.enable("pyright")

-- ── C / C++ ──────────────────────────────────────────────────
vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
}
vim.lsp.enable("clangd")

-- ── Typst ────────────────────────────────────────────────────
vim.lsp.config["tinymist"] = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { ".git" },
	settings = { exportPdf = "onSave", formatterMode = "typstyle" },
}
vim.lsp.enable("tinymist")

-- R
vim.lsp.config["r_language_server"] = {
	cmd = { "R", "--no-echo", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd" },
	root_markers = { ".git", "DESCRIPTION" },
}
vim.lsp.enable("r_language_server")

