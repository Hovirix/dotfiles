local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

------------------------------------------------------
-- Config Options
------------------------------------------------------

config.adjust_window_size_when_changing_font_size = false
do
  local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
  scheme.ansi[5] = "#fab387"   -- blue -> peach
  scheme.brights[5] = "#fab387"
  config.colors = scheme
end

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12
config.hide_tab_bar_if_only_one_tab = true
-- config.line_height = 1.1
config.prefer_to_spawn_tabs = true
config.tab_max_width = 1000
config.use_fancy_tab_bar = false

------------------------------------------------------
--  KeyAssignment enumeration
------------------------------------------------------

config.keys = {
  { key = 'p', mods = 'ALT', action = wezterm.action.ActivateCommandPalette, },
	{ key = 'v', mods = 'ALT', action = act.ActivateCopyMode },

	{ key = 'h', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'l', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = 'k', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = 'j', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },

  { key = 'c', mods = 'ALT', action = wezterm.action.CharSelect },

	-- General 
	{ key = "f", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = ' ', mods = 'ALT', action = wezterm.action.QuickSelect },

	-- Search
	{ key = "/", mods = "ALT", action = act.Search { CaseInSensitiveString = "" } },
	
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

	{ key = 'UpArrow', mods = 'ALT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'ALT', action = act.ScrollByLine(1) },
  { key = 'PageUp', mods = 'ALT', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'ALT', action = act.ScrollByPage(1) },

	-- Resize

	-- Copy mode
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "ALT",
    action = wezterm.action_callback(function(window, pane)
      local tab = window:mux_window():tabs()[i]

      if tab then
        tab:activate()
      else
        window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
      end
    end),
  })

  table.insert(config.keys, {
    key = tostring(i),
    mods = "CTRL|ALT",
    action = act.MoveTab(i),
  })
end
return config

------------------------------------------------------
--  CopyModeAssignment enumeration
------------------------------------------------------
