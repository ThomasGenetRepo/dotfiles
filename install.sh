#!/usr/bin/env bash
# Symlinks this repo's configs into place. Idempotent: correct links are
# left alone; anything else at a target path is backed up first.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" target="$2"

  if [ ! -e "$src" ]; then
    echo "skip: $src does not exist"
    return
  fi

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    echo "ok:   $target"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup
    backup="$target.bak.$(date +%Y%m%d%H%M%S)"
    echo "back: $target -> $backup"
    mv "$target" "$backup"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$src" "$target"
  echo "link: $target -> $src"
}

link shell/bashrc "$HOME/.bashrc"
link readline/inputrc "$HOME/.inputrc"
link tmux/tmux.conf "$HOME/.tmux.conf"
link nvim "$HOME/.config/nvim"
link eza "$HOME/.config/eza"
link superfile "$HOME/.config/superfile"
# On WSL this link is inert (WezTerm reads the Windows-side copy); on
# Linux/macOS it's the live config. See README.
link wezterm "$HOME/.config/wezterm"

# tmux plugin manager; the plugins themselves install with prefix + I.
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "TPM cloned -- start tmux and press prefix + I to install plugins"
fi
