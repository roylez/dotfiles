-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- patterns 
local url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]]
local hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=]
local path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]]

--- {{{ Hooks
wezterm.on("gui-startup", function()
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)
--- }}}

--- {{{ Options
config.color_scheme = 'Tomorrow Night Bright'

config.font = wezterm.font_with_fallback {
  'FantasqueSansMono Nerd Font Mono',
  { family="LXGW WenKai Mono", weight="Bold"}
}

config.font_size = 18
-- no ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.line_height = 1.05

config.use_fancy_tab_bar = false

config.quick_select_patterns = { url_regex, path_regex, hash_regex }

config.enable_kitty_keyboard = true

config.front_end = 'WebGpu'

config.hyperlink_rules = {
  { regex = url_regex, format = "$0" },
  { regex = [=[[-.\w]+@[-.\w]+]=], format = "mailto:$0" }
}

config.initial_cols = 200
config.initial_rows = 80
config.macos_window_background_blur = 20

config.webgpu_power_preference = "HighPerformance"
config.window_background_opacity = 0.90
config.window_close_confirmation = "NeverPrompt"

config.set_environment_variables = {
  PATH = os.getenv('HOME') .. '/bin:'
    .. '/opt/homebrew/bin:/usr/local/bin/:'
    .. os.getenv('PATH')
}

--- }}}

--- keys {{{
act = wezterm.action

config.debug_key_events = true
config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  { mods = 'CMD', key = 'm', action = act.DisableDefaultAssignment, },

  { mods = 'CMD', key = 'd', action = act.ShowDebugOverlay },

  { mods = 'CTRL|SHIFT|SUPER', key = 'r', action = act.ShowLauncherArgs { flags = 'TABS|LAUNCH_MENU_ITEMS' }, },

  { mods = 'CMD', key = 'RightArrow', action = act.ActivateTabRelative(1)  },
  { mods = 'CMD', key = 'LeftArrow',  action = act.ActivateTabRelative(-1) },

  { mods = 'CMD', key = 'e', 
    action = act.SpawnCommandInNewTab {
      label = 'MUTT',
      args = { 'ssh',  '-t', 'limbo', 'zsh', '-ic', '"neomutt -F .mutt/muttrc -F .mutt/account/work"' },
    }
  },

  { 
    mods = 'CTRL|SHIFT|SUPER', key = 'Enter', 
    action = act.SpawnCommandInNewTab {
      label = 'SCRATCH',
      args = { "nvim", "+Startify" }
    }
  },

  { mods = 'CMD', key = 'p', action = act.QuickSelect },
}

--- }}}

--- {{{ launch menu
config.launch_menu = {
  { label = 'MUTT',           args = { 'ssh',  '-t', 'limbo', 'zsh', '-ic', '"neomutt -F .mutt/muttrc"' } },
  { label = 'lf',             args = { "lf", os.getenv("HOME") .. "/Downloads" } },
  { label = 'WezTerm Config', args = { 'nvim', os.getenv("HOME") .. '/.wezterm.lua' } },
}
--- }}}

-- and finally, return the configuration to wezterm
return config
