local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==========================================
-- Tab Titles, Icons & Status Bar
-- ==========================================

local icons = {
  bash = wezterm.nerdfonts.cod_terminal, -- Fixed: dev_terminal does not exist
  vim = wezterm.nerdfonts.dev_vim,
  git = wezterm.nerdfonts.dev_git,
}

-- NOTE: on WSL panes, get_foreground_process_name() always reports
-- wslhost.exe, never the actual process running inside Debian. This is
-- a known WezTerm limitation, not a bug in this code. Until the shell
-- inside WSL pushes its own state out (OSC sequence / user var), this
-- will always fall through to the generic icon below.
local function get_process_name(tab)
  local pane = wezterm.mux.get_pane(tab.active_pane.pane_id)
  if not pane then return "" end

  local name = pane:get_foreground_process_name()
  if not name or name == "" then return "" end

  name = name:gsub("%.exe$", "")
  return name:match("([^/\\]+)$") or ""
end

wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  if title == "wslhost.exe" or title == "" then
    title = "Debian"
  end

  local process = get_process_name(tab)
  local icon = icons[process] or ""
  if icon == "" and process ~= "" then
    -- Fallback generic icon if process is active but not explicitly mapped
    icon = wezterm.nerdfonts.cod_terminal
  end

  return {
    { Text = " " .. tab.tab_index + 1 .. ": " .. icon .. " " .. title .. " " },
  }
end)

-- Adds a simple clock to the empty right side of the tab bar
-- wezterm.on("update-right-status", function(window, pane)
--   window:set_right_status(wezterm.format({
--     { Background = { Color = "#191724" } },
--     { Foreground = { Color = "#908caa" } },
--     { Text = " " .. wezterm.strftime("%H:%M") .. " " },
--   }))
-- end)

-- ==========================================
-- OS Specific Setup
-- ==========================================

local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

config.scrollback_lines = 10000

if is_windows then
  config.wsl_domains = {
    {
      name = "WSL:Debian",
      distribution = "Debian",
      default_cwd = "~",
    },
  }
  config.default_domain = "WSL:Debian"
  config.launch_menu = {
    {
      label = "WSL Debian",
      args = { "wsl.exe", "-d", "Debian" },
    },
    {
      label = "cmd",
      args = { "cmd.exe", "/k" },
    },
  }
--  config.win32_system_backdrop = "Acrylic"
elseif is_macos then
  config.default_prog = { "/bin/zsh", "-l" }
  config.macos_window_background_blur = 30
elseif is_linux then
  config.default_prog = { "/bin/bash", "-l" }
end

-- ==========================================
-- Behaviour & Text Selection
-- ==========================================

-- Keeps full paths, strings, and variables intact when double-clicking text
config.selection_word_boundary = " \t\n{}[]()\"'`,;<>|"

config.keys = {
  -- Ctrl+Shift+E triggers QuickSelect mode (hit the character hint to copy paths/URLs)
  { key = 'E', mods = 'CTRL|SHIFT', action = wezterm.action.QuickSelect },
  -- Ctrl+Shift+F opens a searchable scrollback buffer
  { key = 'F', mods = 'CTRL|SHIFT', action = wezterm.action.Search({ CaseInSensitiveString = "" }) },
}

-- ==========================================
-- Appearance
-- ==========================================

config.color_scheme = "rose-pine-moon"
-- config.window_background_opacity = 0.92
config.window_decorations = "RESIZE" -- Borderless title bar

-- Cursor
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Fonts & Layout
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "Cascadia Code",
  "Cascadia Mono",
  "Consolas",
})
config.font_size = 11.5
config.line_height = 1.0
config.cell_width = 0.95
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- Tab Bar Layout
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 24
config.window_frame = {
  font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
  font_size = 11.0,
}

-- Custom Colors
config.colors = {
  selection_bg = "#403d52",
  selection_fg = "#e0def4",
  tab_bar = {
    background = "#191724",
    active_tab = {
      bg_color = "#26233a",
      fg_color = "#e0def4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#191724",
      fg_color = "#908caa",
    },
    inactive_tab_hover = {
      bg_color = "#1f1d2e",
      fg_color = "#e0def4",
    },
    new_tab = {
      bg_color = "#191724",
      fg_color = "#6e6a86",
    },
    new_tab_hover = {
      bg_color = "#1f1d2e",
      fg_color = "#e0def4",
    },
  },
}

return config
