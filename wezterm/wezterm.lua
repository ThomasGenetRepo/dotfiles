local wezterm = require("wezterm")
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

config.font_size = 12
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.scrollback_lines = 10000

if is_windows then
  config.default_prog = {
    "wsl.exe",
    "-d",
    "Debian",
    "--cd",
    "~",
  }

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
elseif is_macos then
  config.default_prog = { "/bin/zsh", "-l" }
elseif is_linux then
  config.default_prog = { "/bin/bash", "-l" }
end

return config
