#!/usr/bin/env bash
# One-shot setup for a fresh machine: installs the tools the configs
# depend on, symlinks the configs (install.sh), then runs the headless
# post-install steps (tmux plugins, nvim plugins). Idempotent: anything
# already on PATH is skipped, so it is safe to re-run after a partial
# failure or to pick up new tools added later.
#
# Debian/Ubuntu only (apt + GitHub releases). Other OSes: install the
# dependencies from the README by hand, then run install.sh.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

NVM_VERSION="v0.40.3"

mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"
export PATH="$LOCAL_BIN:$PATH"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32mok\033[0m   %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

case "$(uname -m)" in
  x86_64)        ARCH=amd64; NVIM_ARCH=x86_64 ;;
  aarch64|arm64) ARCH=arm64; NVIM_ARCH=arm64 ;;
  *) echo "unsupported arch: $(uname -m)"; exit 1 ;;
esac

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

if ! have apt-get; then
  echo "This script targets Debian/Ubuntu. Elsewhere, install the tools listed in the README and run install.sh."
  exit 1
fi

# Latest release tag of a GitHub repo, e.g. "v1.6.0".
latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1
}

# ---------------------------------------------------------------- apt ----
log "apt packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  git curl ca-certificates tar unzip build-essential \
  bash-completion tmux eza fzf ripgrep fd-find bat git-delta btop lsof \
  python3 python3-venv python3-pip imagemagick fontconfig

# Debian renames these two; the configs expect the upstream names.
[ -e "$LOCAL_BIN/bat" ] || ln -s "$(command -v batcat)" "$LOCAL_BIN/bat"
[ -e "$LOCAL_BIN/fd" ]  || ln -s "$(command -v fdfind)" "$LOCAL_BIN/fd"
ok "apt"

# --------------------------------------------------------------- nvim ----
# Tarball under ~/.local/opt/nvim, binary symlinked into ~/.local/bin.
# Debian's package is too old for the vim.lsp.config API the config uses.
if have nvim; then
  ok "nvim $(nvim --version | head -1)"
else
  log "neovim"
  curl -fsSL -o "$TMP/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
  rm -rf "$LOCAL_OPT/nvim"
  tar -C "$TMP" -xzf "$TMP/nvim.tar.gz"
  mv "$TMP/nvim-linux-${NVIM_ARCH}" "$LOCAL_OPT/nvim"
  ln -sf "$LOCAL_OPT/nvim/bin/nvim" "$LOCAL_BIN/nvim"
  ok "nvim $(nvim --version | head -1)"
fi

# ------------------------------------------------------------- zoxide ----
if have zoxide; then ok "zoxide"; else
  log "zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | sh -s -- --bin-dir "$LOCAL_BIN" --man-dir "$HOME/.local/share/man"
fi

# ----------------------------------------------------------------- gh ----
if have gh; then ok "gh"; else
  log "gh"
  tag="$(latest_tag cli/cli)"; ver="${tag#v}"
  curl -fsSL -o "$TMP/gh.tar.gz" \
    "https://github.com/cli/cli/releases/download/${tag}/gh_${ver}_linux_${ARCH}.tar.gz"
  tar -C "$TMP" -xzf "$TMP/gh.tar.gz"
  install -m 755 "$TMP/gh_${ver}_linux_${ARCH}/bin/gh" "$LOCAL_BIN/gh"
fi

# ----------------------------------------------------------------- uv ----
if have uv; then ok "uv"; else
  log "uv"
  curl -LsSf https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh
fi

# ---------------------------------------------------------- superfile ----
if have spf; then ok "superfile"; else
  log "superfile"
  tag="$(latest_tag yorukot/superfile)"
  curl -fsSL -o "$TMP/spf.tar.gz" \
    "https://github.com/yorukot/superfile/releases/download/${tag}/superfile-linux-${tag}-${ARCH}.tar.gz"
  mkdir -p "$TMP/spf" && tar -C "$TMP/spf" -xzf "$TMP/spf.tar.gz"
  install -m 755 "$(find "$TMP/spf" -type f -name spf | head -1)" "$LOCAL_BIN/spf"
fi

# ---------------------------------------------------------- nvm + node ----
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then ok "nvm"; else
  log "nvm"
  # PROFILE=/dev/null: bashrc already sources nvm; don't let the installer
  # append a second copy.
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE=/dev/null bash
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
if have node; then ok "node $(node --version)"; else
  log "node (lts)"
  nvm install --lts
  nvm alias default lts/*
fi

# ----------------------------------------------------------------- go ----
if [ -x /usr/local/go/bin/go ]; then ok "$(/usr/local/go/bin/go version)"; else
  log "go"
  gover="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
  curl -fsSL -o "$TMP/go.tar.gz" "https://go.dev/dl/${gover}.linux-${ARCH}.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$TMP/go.tar.gz"
fi
export PATH="$PATH:/usr/local/go/bin"

# ---------------------------------------------------------------- font ----
# Under WSL the terminal renders on Windows, so the font goes there by
# hand (see README). Native Linux: user font dir.
if is_wsl; then
  log "WSL detected: install JetBrainsMono Nerd Font on the Windows side manually"
elif fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
  ok "JetBrainsMono Nerd Font"
else
  log "JetBrainsMono Nerd Font"
  fontdir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
  mkdir -p "$fontdir"
  curl -fsSL -o "$TMP/font.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -qo "$TMP/font.zip" -d "$fontdir" '*.ttf'
  fc-cache -f "$fontdir"
fi

# ------------------------------------------------------------ symlinks ----
log "linking configs"
"$DOTFILES/install.sh"

# --------------------------------------------------------- post-install ----
log "tmux plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

log "nvim plugins (headless Lazy sync; Mason tools install on first interactive launch)"
nvim --headless "+Lazy! sync" +qa

cat <<MSG

Done. Remaining manual steps:
  1. Open a new shell (or: exec bash).
  2. gh auth login      # answer "No" to configuring git credentials; gitconfig already wires gh in
  3. cd $DOTFILES && git remote set-url origin git@github.com:ThomasGenetRepo/dotfiles.git   # optional, after adding an SSH key
  4. Launch nvim once interactively so Mason installs its tools.
MSG
is_wsl && echo "  5. Copy wsl/wsl.conf to /etc/wsl.conf (sudo) and wsl/.wslconfig to %UserProfile%; install the Nerd Font + WezTerm config on Windows."
exit 0
