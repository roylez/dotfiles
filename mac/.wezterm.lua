-- {{{ Variables
-- Pull in the wezterm API
--
local wezterm = require 'wezterm'
-- This will hold the configuration.
local config = wezterm.config_builder()

local home = os.getenv('HOME')
local url_regex = [[https?://[^<>"\s{-}\^⟨⟩`│⏎]+]]
local hash_regex = [=[[a-f\d]{4,}|[A-Z_]{4,}]=]
local path_regex = [[~?(?:[-.\w]*/)+[-.\w]*]]

local info = wezterm.log_info
--- }}}

--- {{{ Options

config.font = wezterm.font_with_fallback {
  'Fantasque Sans Mono',
  {family="LXGW WenKai Mono TC", weight="Regular", stretch="Normal", style="Normal"}
}

config.font_size = 17
-- no ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.line_height = 1.05

config.use_fancy_tab_bar = false

config.switch_to_last_active_tab_when_closing_tab = true

config.default_cursor_style = "BlinkingBar"

config.cursor_blink_rate = 700

config.status_update_interval = 1000

config.quick_select_patterns = { url_regex, path_regex, hash_regex }

config.enable_kitty_keyboard = true

config.default_cwd = '~'

config.front_end = 'OpenGL'

config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- make username/project paths clickable. this implies paths like the following are for github.
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = 'https://www.github.com/$1/$3',
})

config.initial_cols = 200
config.initial_rows = 80

config.webgpu_power_preference = "HighPerformance"
config.window_close_confirmation = "NeverPrompt"

config.set_environment_variables = {
  PATH = os.getenv('HOME') .. '/bin:'
    .. '/opt/homebrew/bin:/usr/local/bin/:'
    .. os.getenv('PATH')
}

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0',
  bottom = '0',
}

--- {{{ launch menu
config.launch_menu = {
  { label = 'MUTT',           args = { 'ssh',  '-t', 'limbo', 'zsh', '-ic', '"neomutt -F .mutt/muttrc"' } },
  { label = 'TASKPAPER',      args = { 'nvim', home .. "/Documents/TODO.taskpaper" } },
  { label = 'lf',             args = { "lf",   home .. "/Downloads"                } },
  { label = 'WezTerm Config', args = { 'nvim', home .. '/.wezterm.lua'             } },
}
--- }}}
--- }}}

--- Keys {{{
act = wezterm.action

config.debug_key_events = true

function launch_named_tab(title, args)
  return wezterm.action_callback(function(window, pane)
    local tab, pane, window = window:mux_window():spawn_tab { args = args }
    tab:set_title(title)
  end)
end

config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  { mods = 'CMD', key = 'm', action = act.DisableDefaultAssignment, },

  { mods = 'CMD|SHIFT', key = 'd', action = act.ShowDebugOverlay },

  {
    mods = 'CTRL|SHIFT|SUPER', key = 'r',
    action = act.ShowLauncherArgs {
      title = 'RUN...',
      flags = 'TABS|LAUNCH_MENU_ITEMS|KEY_ASSIGNMENTS',
    },
  },

  { mods = 'CMD', key = 'LeftArrow',  action = act.ActivateTabRelative(-1) },
  { mods = 'CMD', key = 'RightArrow', action = act.ActivateTabRelative(1)  },
  { mods = 'CMD', key = 'h',          action = act.ActivateTabRelative(-1)  },
  { mods = 'CMD', key = 'l',          action = act.ActivateTabRelative(1) },

  {
    mods = 'CMD', key = 'e',
    action = launch_named_tab("MUTT", { 'ssh',  '-t', 'limbo', 'zsh', '-ic', '"neomutt -F .mutt/muttrc -F .mutt/account/work"' })
  },

  {
    mods = 'CMD', key = 'd',
    action = launch_named_tab("TASKPAPER", { 'nvim', home .. "/Documents/TODO.taskpaper" } )
  },

  { mods = 'CTRL|SHIFT|SUPER', key = 'Enter',
    action = act.SpawnCommandInNewTab { args = { "nvim", "+Startify" } }
  },

  { mods = 'CMD', key = 'p', action = act.QuickSelect },

  {
    mods = 'CMD', key = 'o',
    action = act.QuickSelectArgs {
      label = 'open url',
      patterns = { url_regex },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        info('Opening URL: ' .. url)
        wezterm.open_with(url)
      end),
    }
  },
}

--- }}}

--- {{{ Multiplexing
config.unix_domains = {
  { name = 'unix' }
}

config.default_gui_startup_args = { 'connect', 'unix' }
-- }}}

--- {{{ Colors
config.macos_window_background_blur = 10
config.window_background_opacity = 0.70
config.text_background_opacity = 0.75

config.color_scheme = 'Tomorrow Night Eighties'

--- }}}

--- {{{ Hooks

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

-- AnsiColors:
-- Black, Maroon, Green, Olive, Navy, Purple, Teal, Silver, Grey, Red, Lime, Yellow, Blue, Fuchsia, Aqua or White
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, _)
  local palette = conf.resolved_palette
  local index = tab.tab_index + 1
  local active = tab.is_active
  local title = tab_title(tab)
  local fg = active and { AnsiColor = 'Black' } or { AnsiColor = 'Silver' }
  local bg = active and { AnsiColor = 'White' } or { Color = palette.background }
  local intensity = active and {Intensity='Bold'} or {Intensity = 'Half'}
  local italic = {Italic=false}

  return {
    { Attribute = intensity },
    { Attribute = italic },
    { Background = bg },
    { Foreground = fg },
    { Text = "  " .. index .. " " .. title .. "  " },
  }
  -- if #panes == 1 then
  --   return {
  --     { Attribute = intensity },
  --     { Attribute = italic },
  --     { Background = bg },
  --     { Foreground = fg },
  --     { Text = "  " .. index .. " " .. title .. "  " },
  --   }
  -- else
  --   return {
  --     { Attribute = intensity },
  --     { Attribute = italic },
  --     { Background = bg },
  --     { Foreground = fg },
  --     { Text = "  " .. index },
  --     { Foreground = {AnsiColor = 'Red'} },
  --     { Text = "+" },
  --     { Foreground = fg },
  --     { Text = " " .. title .. "  " },
  --   }
  -- end
end)

function get_date()
  local date = wezterm.strftime("%b %d")
  if wezterm.strftime("%u") > "5" then
    return { icon = "󰧓 ", color = "#f2e8cf", text = date }
  else
    return { icon = "󰃵 ", color = "#2a9d8f" ,text = date }
  end
end

function get_time()
  local time = wezterm.strftime("%H:%M")
  return { icon = " ", color = "#669bbc" , text = time }
end

function get_todo()
  local out = io.popen("whoami"):read("*a"):gsub("\n", "")
  if #out > 1 then
    return { icon = " ", color = "#d62828", text = out }
  else
    return nil
  end
end

function add_status_item(cells, item)
  if item then
    table.insert(cells, { Foreground = { Color = item.color }})
    table.insert(cells, { Text = item.icon .. " "})
    table.insert(cells, "ResetAttributes")
    table.insert(cells, { Text = item.text .. "  " })
  end
  return cells
end

wezterm.on("update-right-status", function(window, pane)
  local data = { get_todo(), get_time(), get_date() }
  local cells = {}

  for _, item in pairs(data) do
    cells = add_status_item(cells, item)
  end

  window:set_right_status(wezterm.format(cells))
end)

--- }}}

return config
