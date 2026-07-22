-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Set the color scheme
-- config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "Github Dark"
-- config.color_scheme = "GruvboxDark"
-- config.color_scheme = "GruvboxDarkHard"
config.color_scheme = "rose-pine"
-- config.color_scheme = "Dracula"
--config.color_scheme = "Kanagawa (Gogh)"

-- This is where you actually apply your config choices

--config.font = wezterm.font("Maple Mono")
--config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font = wezterm.font("Iosevka Nerd Font")
--config.font = wezterm.font("Fira Code")

config.font_size = 20
config.line_height = 1.2

config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.4
config.macos_window_background_blur = 60

config.scrollback_lines = 10000

-- config.initial_rows = 50
-- config.initial_cols = 20

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

return config
