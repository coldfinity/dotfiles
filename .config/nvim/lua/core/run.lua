local interpreters = {
	go = { "go", "run" },
	java = { "java" },
	javascript = { "node" },
	python = { "python3" },
	r = { "Rscript" },
	ruby = { "ruby" },
	swift = { "swift" },
	zsh = { "zsh" },
}

local compilers = {
	c = "cc",
	cpp = "c++",
	rust = "rustc",
}

local function file_command(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" or vim.bo[buf].buftype ~= "" then
		return
	end

	local ft = vim.bo[buf].filetype
	local compiler = compilers[ft]
	if compiler and vim.fn.executable(compiler) == 1 and not path:match("%.h[%w+]*$") then
		local output = vim.fn.tempname()
		return { "sh", "-c", '"$1" "$2" -o "$3" && exec "$3"', "run", compiler, path, output }, output
	end

	local command = interpreters[ft]
	if ft == "lua" then
		command = { vim.fn.executable("lua") == 1 and "lua" or "luajit" }
	elseif ft == "sh" then
		command = { vim.b[buf].is_bash == 1 and "bash" or "sh" }
	elseif ft == "typescript" then
		command = { vim.fn.executable("tsx") == 1 and "tsx" or "node" }
	end

	if command and vim.fn.executable(command[1]) == 1 then
		return vim.list_extend(vim.deepcopy(command), { path })
	end
end

local runner_buf, runner_job

local function run(command, source, cwd, output)
	if runner_job and vim.fn.jobwait({ runner_job }, 0)[1] == -1 then
		vim.notify("A command is already running. Stop it with Ctrl-C in the run terminal.", vim.log.levels.WARN)
		return
	end

	if
		vim.api.nvim_buf_is_valid(source)
		and vim.bo[source].buftype == ""
		and vim.api.nvim_buf_get_name(source) ~= ""
	then
		local ok, err = pcall(vim.api.nvim_buf_call, source, function()
			vim.cmd.update()
		end)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end

	local win = runner_buf and vim.fn.bufwinid(runner_buf) or -1
	if win == -1 then
		vim.cmd("botright 12new")
	else
		vim.api.nvim_set_current_win(win)
		vim.cmd.enew()
	end
	runner_buf = vim.api.nvim_get_current_buf()
	vim.bo.bufhidden = "wipe"
	vim.bo.buflisted = false
	runner_job = vim.fn.jobstart(command, {
		term = true,
		cwd = cwd,
		on_exit = output and function()
			vim.uv.fs_unlink(output)
		end or nil,
	})
	if runner_job > 0 then
		vim.cmd.startinsert()
	end
end

vim.api.nvim_create_user_command("Run", function(opts)
	local source = vim.api.nvim_get_current_buf()
	local cwd = vim.fn.getcwd()
	if opts.args ~= "" then
		run(opts.args, source, cwd)
		return
	end

	local command, output = file_command(source)
	if command then
		run(command, source, cwd, output)
		return
	end

	vim.ui.input({ prompt = "Run command: " }, function(input)
		if input and vim.trim(input) ~= "" then
			run(input, source, cwd)
		end
	end)
end, { nargs = "*", desc = "Run a command or the current file" })

require("core.map")("n", "<leader>r", "<cmd>Run<cr>", "Run current file")
