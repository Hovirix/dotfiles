local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()


window_close_confirmation = "NeverPrompt"

------------------------------------------------------
-- Appearance
------------------------------------------------------
config.color_scheme = "Catppuccin Mocha"
config.colors = {
  ansi = {
    "#45475a",
    "#f38ba8",
    "#a6e3a1",
    "#f9e2af",
    "#fab387", -- Peach instead of Blue
    "#f5c2e7",
    "#94e2d5",
    "#bac2de",
  },

  brights = {
    "#585b70",
    "#f38ba8",
    "#a6e3a1",
    "#f9e2af",
    "#fab387", -- Peach instead of Blue
    "#f5c2e7",
    "#94e2d5",
    "#a6adc8",
  },
}

config.font_size = 12
-- config.line_height = 1.1
config.font = wezterm.font("JetBrains Mono")

config.tab_max_width = 1000
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.adjust_window_size_when_changing_font_size = false

------------------------------------------------------
--  Keybidings
------------------------------------------------------

config.disable_default_key_bindings = true

config.keys = {

	-- General 
	{ key = "f", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = 'p', mods = 'ALT', action = wezterm.action.ActivateCommandPalette, },
  { key = ' ', mods = 'ALT', action = wezterm.action.QuickSelect },

	-- Search
	{ key = "s", mods = "CTRL", action = act.Search { CaseInSensitiveString = "" } },
	
	-- Copy / Paste
	{ key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },

	-- Focus / Move 
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },

	-- Splits 
	{ key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "=", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- Resize
	{ key = 'h', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'l', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = 'k', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = 'j', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },

	-- Copy mode
	{ key = 'y', mods = 'ALT', action = act.ActivateCopyMode },
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local tabs = window:mux_window():tabs()
			if tabs[i] then
				window:perform_action(act.ActivateTab(i - 1), pane)
			else
				window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
			end
		end),
	})
end
return config
