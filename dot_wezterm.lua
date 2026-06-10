local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

------------------------------------------------------
-- Config Options
------------------------------------------------------

config.adjust_window_size_when_changing_font_size = false

do
  local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
  scheme.ansi[5] = "#fab387"
  scheme.brights[5] = "#fab387"

  scheme.tab_bar = {
    background = "#1e1e2e",

    active_tab = {
      bg_color = "#fab387",
      fg_color = "#1e1e2e",
    },

    inactive_tab = {
      bg_color = "#181825",
      fg_color = "#cdd6f4",
    },

    inactive_tab_hover = {
      bg_color = "#313244",
      fg_color = "#fab387",
    },

    new_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#9399b2",
    },

    new_tab_hover = {
      bg_color = "#313244",
      fg_color = "#fab387",
    },
  }

  config.colors = scheme
end

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12
config.hide_tab_bar_if_only_one_tab = true
config.prefer_to_spawn_tabs = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32
config.use_fancy_tab_bar = false

------------------------------------------------------
-- Tab Helpers
------------------------------------------------------

local function activate_or_spawn_slot(window, _pane, slot)
  local mux_window = window:mux_window()
  local target_index = slot - 1

  for _, tab_info in ipairs(mux_window:tabs_with_info()) do
    if tab_info.index == target_index then
      tab_info.tab:activate()
      return
    end
  end

  local tab
  repeat
    tab = mux_window:spawn_tab({})
  until #mux_window:tabs_with_info() > target_index

  tab:activate()
end

------------------------------------------------------
-- Key Assignments
------------------------------------------------------

config.keys = {
  -- Utility
  { key = " ", mods = "ALT", action = act.QuickSelect },
  { key = "/", mods = "ALT", action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "c", mods = "ALT", action = act.CharSelect },
  { key = "v", mods = "ALT", action = act.ActivateCopyMode },

  -- Clipboard
  { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },

  -- Panes
  { key = "f", mods = "ALT", action = act.TogglePaneZoomState },
  { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },

  -- Pane resize
  { key = "h", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "j", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "k", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "l", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Splits
  { key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "=", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Scrollback
  { key = "UpArrow", mods = "ALT", action = act.ScrollByLine(-1) },
  { key = "DownArrow", mods = "ALT", action = act.ScrollByLine(1) },
  { key = "PageUp", mods = "ALT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "ALT", action = act.ScrollByPage(1) },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "ALT",
    action = wezterm.action_callback(function(window, pane)
      activate_or_spawn_slot(window, pane, i)
    end),
  })

  table.insert(config.keys, {
    key = tostring(i),
    mods = "CTRL|ALT",
    action = act.MoveTab(i - 1),
  })
end

return config
