local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

------------------------------------------------------
-- Appearance
------------------------------------------------------

-- config.color_scheme = "catppuccin-mocha"
config.color_scheme = "Catppuccin Mocha"

config.font_size = 12
config.font = wezterm.font("JetBrains Mono")

config.hide_tab_bar_if_only_one_tab = true
config.adjust_window_size_when_changing_font_size = false

------------------------------------------------------
--  Keybidings
------------------------------------------------------

-- config.disable_default_key_bindings = true

config.keys = {

	-- === General ===
	{ key = "f", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },

	-- === Focus / Move ===
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },

	-- === Splits ===
	{ key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "=", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
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
