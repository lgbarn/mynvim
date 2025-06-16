-- wezterm API helpers --------------------------------------------------------
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-------------------------------------------------------------------------------
-- Appearance
-------------------------------------------------------------------------------
-- Try with font fallback for better character support
config.font = wezterm.font_with_fallback({
	"MesloLGS Nerd Font Mono",
	"Menlo",
	"Monaco",
	"Consolas",
})
config.font_size = 16

-- Explicitly enable font features that might help with underscores
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Adjust line height slightly - sometimes helps with character clipping
config.line_height = 1.1 -- Changed from 1.05

config.enable_tab_bar = false
config.window_decorations = "TITLE|RESIZE"
config.window_background_opacity = 1
config.macos_window_background_blur = 10
config.enable_scroll_bar = true
config.scrollback_lines = 20000

config.selection_word_boundary = " \t\n{}[]()\"'`,;:|"
config.term = "xterm-256color"

-- Harmonised cool-night palette
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = {
		"#0B253A",
		"#E85252",
		"#44FFB1",
		"#FFD27A",
		"#1FA8FF",
		"#A277FF",
		"#24EAF7",
		"#BEE5FF",
	},
	brights = {
		"#4B6A87",
		"#FF6B6B",
		"#67FFC3",
		"#FFE89A",
		"#4DB5FF",
		"#C09BFF",
		"#5AEDFF",
		"#FFFFFF",
	},
}

-------------------------------------------------------------------------------
-- Mouse bindings
-------------------------------------------------------------------------------
config.disable_default_mouse_bindings = false

config.mouse_bindings = {
	-- Copy on selection release (PuTTY style)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},

	-- Right-click → paste (PuTTY style)
	{ event = { Down = { streak = 1, button = "Right" } }, mods = "NONE", action = act.PasteFrom("Clipboard") },

	-- Disable middle-click paste only
	{ event = { Down = { streak = 1, button = "Middle" } }, mods = "NONE", action = act.DisableDefaultAssignment },
}

-------------------------------------------------------------------------------
-- Custom window title (user@host — dir)
-------------------------------------------------------------------------------
wezterm.on("format-window-title", function(_, pane)
	local host = (pane:get_hostname() or ""):gsub("%.local$", ""):match("^[^.]+")
	local cwd = ""
	local uri = pane:get_current_working_dir()
	if uri then
		cwd = uri.file_path:match("[^/\\]+$") or ""
	end
	return string.format("%s@%s — %s", os.getenv("USER") or "", host, cwd)
end)

-------------------------------------------------------------------------------
-- Quality-of-life tweaks
-------------------------------------------------------------------------------
-- Increased window padding to prevent character clipping
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 } -- Increased padding
config.audible_bell = "Disabled"

-- Disable exit confirmation - for *nix admins who know what they're doing
config.window_close_confirmation = "NeverPrompt"

-------------------------------------------------------------------------------
-- Pane-split leader (Ctrl-a  v / s)
-------------------------------------------------------------------------------
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
}

-------------------------------------------------------------------------------
-- Clock on the right side of the title bar
-------------------------------------------------------------------------------
wezterm.on("update-right-status", function(win, _)
	win:set_right_status(wezterm.format({ { Text = wezterm.strftime("%H:%M %Z") } }))
end)

-------------------------------------------------------------------------------
-- Hand back the config
-------------------------------------------------------------------------------
return config
