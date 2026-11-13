-- ── plugins/init.lua ─────────────────────────────────────────
-- Each file below installs its own plugins with vim.pack.add
-- (built-in manager, Nvim 0.12) and then configures them.
-- Update everything with :lua vim.pack.update()
--
-- Order matters only where noted. Comment a line out to disable
-- a whole group.
-- ─────────────────────────────────────────────────────────────

local modules = {
	"mason", -- first: prepends mason's bin dir to PATH for core/lsp.lua
	"treesitter",
	"filetypes",
	"completion",
	"format",
	"dap",
	"colorscheme", -- before statusline/ui so "auto" themes pick it up
	"statusline",
	"ui",
	"navigation",
	"git",
	"editing",
	"diagnostics",
	"ai",
}

for _, name in ipairs(modules) do
	require("plugins." .. name)
end
