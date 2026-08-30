alias cfg_wezterm="nvim ~/src/dotfiles/wezterm/wezterm.lua"
alias cfg_nvim="nvim ~/src/dotfiles/nvim/init.lua"
alias cfg_tmux="nvim ~/src/dotfiles/tmux/tmux.conf"

# --- eza (modern ls) --------------------------------------------------------
# Real ls stays available as `\ls` or `command ls`.
if command -v eza >/dev/null 2>&1; then
  # Shared flags applied to every alias below.
  _eza_flags="--group-directories-first --icons=auto --color=auto"

  alias ls="eza $_eza_flags"                                          # plain ls (grid)
  alias l="eza $_eza_flags --oneline"                                 # one per line, names only
  alias ll="eza $_eza_flags --long --header --git --time-style=long-iso"  # long + git
  alias la="eza $_eza_flags --long --header --git --all --time-style=long-iso"  # + hidden
  alias lt="eza $_eza_flags --tree --level=2"                         # tree, 2 deep
  alias lta="eza $_eza_flags --tree --level=2 --all"                  # tree + hidden

  unset _eza_flags # only needed while defining the aliases above
fi
