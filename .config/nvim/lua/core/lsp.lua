-- ── core/lsp.lua ─────────────────────────────────────────────
-- Uses the native vim.lsp.config / vim.lsp.enable API from Nvim 0.12.
-- Servers are installed via mason (:Mason).
-- ─────────────────────────────────────────────────────────────

local blink_ok, blink = pcall(require, "blink.cmp")
vim.lsp.config("*", {
	capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities(),
})

-- diagnostics
vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { prefix = "●" },
	float = { border = "rounded", source = true },
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
	root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
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
	single_file_support = true,
	settings = { exportPdf = "onSave", formatterMode = "typstyle" },
}
vim.lsp.enable("tinymist")

-- ── TypeScript / JavaScript ──────────────────────────────────
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}
vim.lsp.enable("ts_ls")

-- ── HTML ─────────────────────────────────────────────────────
vim.lsp.config["html"] = {
	cmd = { "html-lsp", "--stdio" },
	filetypes = { "html" },
	root_markers = { "package.json", ".git" },
}
vim.lsp.enable("html")

-- ── CSS ──────────────────────────────────────────────────────
vim.lsp.config["cssls"] = {
	cmd = { "css-lsp", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
}
vim.lsp.enable("cssls")

-- ── Tailwind CSS ─────────────────────────────────────────────
vim.lsp.config["tailwindcss"] = {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json", ".git" },
}
vim.lsp.enable("tailwindcss")

-- ── LTeX (LaTeX/grammar in markdown) ─────────────────────────
vim.lsp.config["ltex"] = {
	cmd = { "ltex-ls" },
	filetypes = { "markdown", "tex" },
	root_markers = { ".git" },
	settings = {
		ltex = { language = "en-US" },
	},
}
vim.lsp.enable("ltex")

-- ── R  ─────────────────────────────────────────────
vim.lsp.config["r_language_server"] = {
	cmd = { "R", "--no-echo", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd" },
	root_markers = { ".git", "DESCRIPTION" },
}
vim.lsp.enable("r_language_server")

-- ── Swift ─────────────────────────
vim.lsp.config("sourcekit", {
	cmd = { "xcrun", "sourcekit-lsp" },
	filetypes = { "swift" },
})
vim.lsp.enable("sourcekit")
