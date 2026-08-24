local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

------------------------------------------------------
-- Config Options
------------------------------------------------------

do
  local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
  scheme.ansi[5] = "#fab387"
  scheme.brights[5] = "#fab387"

  config.colors = scheme
end

config.default_domain = "local"
config.default_gui_startup_args = { "start" }

config.enable_tab_bar = false
config.disable_default_key_bindings = true

config.adjust_window_size_when_changing_font_size = false

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12

config.window_padding = {
  top = 0,
  bottom = 0,
  left = 0,
  right = 0,
}

------------------------------------------------------
-- Key Assignments
------------------------------------------------------

config.keys = {
  -- Utility
  { key = " ", mods = "ALT", action = act.QuickSelect },
  { key = "/", mods = "ALT", action = act.Search({ CaseInSensitiveString = "" }) },

  -- Clipboard
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- Scrollback
  { key = "UpArrow", mods = "ALT", action = act.ScrollByLine(-1) },
  { key = "DownArrow", mods = "ALT", action = act.ScrollByLine(1) },
  { key = "PageUp", mods = "ALT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "ALT", action = act.ScrollByPage(1) },
}

return config
