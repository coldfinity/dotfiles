local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		r = { "styler" },
		typst = { "typstyle" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
	},
	formatters = {
		styler = {
			-- styler defaults to tidyverse_style() (2 spaces); use the buffer's
			-- own indent settings instead
			args = function(_, ctx)
				local sw = vim.bo[ctx.buf].shiftwidth
				if sw == 0 then
					sw = vim.bo[ctx.buf].tabstop
				end
				return {
					"-s",
					"-e",
					string.format(
						"styler::style_file(commandArgs(TRUE), transformers = styler::tidyverse_style(indent_by = %d))",
						sw
					),
					"--args",
					"$FILENAME",
				}
			end,
		},
		clang_format = {
			-- clang-format defaults to LLVM style (2 spaces); use the buffer's
			-- own indent settings instead
			prepend_args = function(_, ctx)
				local ts = vim.bo[ctx.buf].tabstop
				-- 'shiftwidth' of 0 means "follow tabstop"
				local sw = vim.bo[ctx.buf].shiftwidth
				if sw == 0 then
					sw = ts
				end
				local use_tab = vim.bo[ctx.buf].expandtab and "Never" or "ForIndentation"
				return {
					"--style="
						.. string.format(
							"{BasedOnStyle: LLVM, IndentWidth: %d, TabWidth: %d, UseTab: %s}",
							sw,
							ts,
							use_tab
						),
				}
			end,
		},
	},
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
})
