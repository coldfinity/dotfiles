-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Set the color scheme
config.color_scheme = "Catppuccin Mocha"

-- This is where you actually apply your config choices

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16
config.line_height = 1.3

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.5
config.macos_window_background_blur = 80

config.initial_rows = 50
config.initial_cols = 200

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- and finally, return the configuration to wezterm
return config
