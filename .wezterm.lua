-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Set the color scheme
-- config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "Github Dark"
-- config.color_scheme = "GruvboxDark"
-- config.color_scheme = "GruvboxDarkHard"
-- config.color_scheme = "rose-pine"
-- config.color_scheme = "Dracula"
config.color_scheme = "Kanagawa (Gogh)"

-- This is where you actually apply your config choices

-- config.font = wezterm.font("Maple Mono")
config.font = wezterm.font("JetBrainsMono Nerd Font")

config.font_size = 18
config.line_height = 1.5

config.enable_tab_bar = false
config.use_fancy_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.4
config.macos_window_background_blur = 80

config.initial_rows = 50
config.initial_cols = 200

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

return config
