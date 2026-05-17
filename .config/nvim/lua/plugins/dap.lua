local dap_ok, dap = pcall(require, "dap")
if not dap_ok then return end

local ui_ok, dapui = pcall(require, "dapui")
if ui_ok then
	dapui.setup()
	dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
	dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
	dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end

-- Python: debugpy installed via mason
local py_ok, dap_python = pcall(require, "dap-python")
if py_ok then
	dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
end

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

local map = function(k, v, d) vim.keymap.set("n", k, v, { desc = d }) end
map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional breakpoint")
map("<leader>dc", dap.continue, "Continue / start")
map("<leader>dn", dap.step_over, "Step over")
map("<leader>di", dap.step_into, "Step into")
map("<leader>do", dap.step_out, "Step out")
map("<leader>dr", dap.repl.open, "Open REPL")
if ui_ok then
	map("<leader>du", dapui.toggle, "Toggle DAP UI")
end
