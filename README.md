# dotfiles

Personal configs for a bash + tmux + Neovim + WezTerm setup. Currently
driven from WSL2 Debian; a macOS pass is pending.

## Install

The shell config hardcodes its own location, so the repo must live at
`~/src/dotfiles`:

```sh
git clone <repo-url> ~/src/dotfiles
~/src/dotfiles/install.sh
```

`install.sh` is idempotent: correct symlinks are left alone, and anything
else already sitting at a target path is backed up (`*.bak.<timestamp>`)
before being replaced. It also clones TPM if missing.

### What links where

| Repo path         | Target                    | Notes                                       |
| ----------------- | ------------------------- | ------------------------------------------- |
| `shell/bashrc`    | `~/.bashrc`               | Sources the rest of `shell/` by path        |
| `readline/inputrc`| `~/.inputrc`              | History search on arrows, completion tweaks |
| `tmux/tmux.conf`  | `~/.tmux.conf`            |                                             |
| `nvim/`           | `~/.config/nvim`          |                                             |
| `eza/`            | `~/.config/eza`           | Theme only                                  |
| `superfile/`      | `~/.config/superfile`     |                                             |
| `wezterm/`        | `~/.config/wezterm`       | See WSL note below                          |
| `wsl/wsl.conf`    | `/etc/wsl.conf`           | Reference copy — copy manually (sudo)       |
| `wsl/.wslconfig`  | `%UserProfile%\.wslconfig`| Reference copy — copy manually (Windows)    |

**WezTerm on WSL:** WezTerm runs on the Windows side and reads its config
from the Windows filesystem, not from `~/.config/wezterm` inside the
distro. Keep the Windows-side copy in sync with `wezterm/wezterm.lua`
manually. On Linux/macOS the symlink above is the real config.

### After first run

- **tmux**: start tmux and press `prefix + I` to install plugins via TPM.
- **nvim**: first launch bootstraps lazy.nvim, then installs plugins,
  Mason tools, and treesitter parsers on its own. Give it a minute.
- Keybinding reference: [`nvim_tmux_cheat_sheet.md`](nvim_tmux_cheat_sheet.md).

## Dependencies

Required for the core setup to work as configured:

- **git**, **bash**, **tmux**, **Neovim ≥ 0.11** (uses the native
  `vim.lsp.config`/`vim.lsp.enable` API), **WezTerm**
- **JetBrainsMono Nerd Font** — installed on the machine that renders the
  terminal (the Windows host under WSL)
- **eza** (ls aliases), **fzf ≥ 0.48** (shell keybindings via
  `fzf --bash`, tmux-fzf, fzf-lua), **ripgrep** (live grep), **bat**
  (superfile previews), **zoxide** (`cd` frecency jumps + superfile)
- Toolchains Mason shells out to when installing servers/formatters:
  **node** (via nvm), **go**, **python3** (with venv), plus **uv** —
  ruff runs through `uv run` so projects use their pinned version

Optional / nice to have:

- **superfile** (file manager; `spf` wrapper cd's on quit)
- **fd** (faster fzf-lua file finding), **lsof** (`whoport`)
- **imagemagick** (image.nvim rendering), **terraform** (`tfsummary`,
  terraform_fmt)
- **lazygit**, **btop** (on the tmux-resurrect restore whitelist)

## Machine-specific bits to remember

- `tmux/tmux.conf` pins tmux-net-speed to `eth0` — that's `en0` on macOS.
- `shell/bashrc` is bash-only; macOS defaults to zsh (macOS pass pending).
- `sync_obs` (shell/functions.sh) expects the Obsidian vault at
  `~/work/documentation/central-vault`.
- Per-machine shell config (work env vars, secrets, path overrides)
  goes in `~/.bashrc.local` — sourced last by bashrc, never tracked.
