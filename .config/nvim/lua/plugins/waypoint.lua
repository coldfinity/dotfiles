local ok, waypoint = pcall(require, "waypoint")
if not ok then
	return
end

waypoint.setup({
	keymap = false,
})
