vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mfussenegger/nvim-dap-python",
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Python: debugpy installed via mason
require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

-- C/C++: codelldb installed via mason
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}
dap.configurations.c = {
	{
		name = "Launch",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}
dap.configurations.cpp = dap.configurations.c

-- ── keymaps ──────────────────────────────────────────────────
local map = require("core.map")
map("n", "<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, "Conditional breakpoint")
map("n", "<leader>dc", dap.continue, "Continue / start")
map("n", "<leader>dn", dap.step_over, "Step over")
map("n", "<leader>di", dap.step_into, "Step into")
map("n", "<leader>do", dap.step_out, "Step out")
map("n", "<leader>dr", dap.repl.open, "Open REPL")
map("n", "<leader>du", dapui.toggle, "Toggle DAP UI")
