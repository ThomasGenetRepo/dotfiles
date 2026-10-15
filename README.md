# dotfiles

Personal configs for a bash + tmux + Neovim + WezTerm setup. Currently
driven from WSL2 Debian; a macOS pass is pending.

## Install

The shell config hardcodes its own location, so the repo must live at
`~/src/dotfiles`. Clone over HTTPS first: a fresh machine has no SSH key
yet, and `gh auth login` (step 2 below) makes HTTPS pushes work anyway.

```sh
git clone https://github.com/ThomasGenetRepo/dotfiles.git ~/src/dotfiles
~/src/dotfiles/bootstrap.sh
```

`bootstrap.sh` (Debian/Ubuntu) does the whole thing: installs every
dependency listed below, runs `install.sh`, then installs tmux and nvim
plugins headlessly. It skips anything already present, so re-run it
freely. It needs `sudo` for apt and for Go under `/usr/local/go`.

On a machine where the tools are already installed (e.g. via Homebrew),
skip bootstrap and just run `install.sh` plus the two commands under
"After first run".

Afterwards, by hand:

1. Open a new shell.
2. `gh auth login`, answering **No** when it offers to configure git
   credentials -- the tracked gitconfig already routes GitHub auth
   through `gh`.
3. Launch nvim once interactively so Mason installs its servers and
   formatters.
4. Optionally switch the remote to SSH once a key is registered:
   `git remote set-url origin git@github.com:ThomasGenetRepo/dotfiles.git`.

### Configs only

`install.sh` on its own just symlinks. It is idempotent: correct symlinks
are left alone, and anything else already sitting at a target path is
backed up (`*.bak.<timestamp>`) before being replaced. It also clones TPM
if missing.

### What links where

| Repo path         | Target                    | Notes                                       |
| ----------------- | ------------------------- | ------------------------------------------- |
| `shell/bashrc`    | `~/.bashrc`               | Sources the rest of `shell/` by path        |
| `readline/inputrc`| `~/.inputrc`              | History search on arrows, completion tweaks |
| `git/gitconfig`   | `~/.gitconfig`            | Includes `~/.gitconfig.local` (untracked)   |
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

`bootstrap.sh` already did these; only needed after a bare `install.sh`:

- **tmux**: `~/.tmux/plugins/tpm/bin/install_plugins`, or `prefix + I`
  inside tmux.
- **nvim**: `nvim --headless "+Lazy! sync" +qa`, or just launch it; first
  start bootstraps lazy.nvim, then installs plugins, Mason tools, and
  treesitter parsers on its own. Give it a minute.
- Keybinding reference: [`nvim_tmux_cheat_sheet.md`](nvim_tmux_cheat_sheet.md).

## Dependencies

All installed by `bootstrap.sh` on Debian (apt where the packaged version
is recent enough, GitHub releases into `~/.local/bin` otherwise).
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
- Per-machine git config (alternate identity, signing key, URL rewrites)
  goes in `~/.gitconfig.local` — included last by gitconfig, never tracked.
