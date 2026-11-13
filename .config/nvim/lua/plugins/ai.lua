vim.pack.add({ "https://github.com/coder/claudecode.nvim" })

require("claudecode").setup()

local map = require("core.map")
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude")
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude")
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude")
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", "Continue Claude")
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", "Select model")
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add buffer to Claude")
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection to Claude")
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff")
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Deny diff")
