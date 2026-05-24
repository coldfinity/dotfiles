local ok, claudecode = pcall(require, "claudecode")
if not ok then
	return
end

claudecode.setup()
