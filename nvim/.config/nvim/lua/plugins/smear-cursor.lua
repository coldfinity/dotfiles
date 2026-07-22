local ok, smear = pcall(require, "smear_cursor")
if not ok then
	return
end

smear.setup({
	stiffness = 0.8,
	trailing_stiffness = 0.5,
	distance_stop_animating = 0.5,
	hide_target_hack = false,
})
