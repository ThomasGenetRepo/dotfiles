# cool utility functions to call in ~/.bashrc (or other shell)

mkcd() {
  mkdir -p "$1" && cd "$1"
}

whoport() {
  if [ -z "$1" ]; then
    echo "usage: whoport <port>"
    return 1
  fi

  if ! command -v lsof >/dev/null 2>&1; then
    echo "error: lsof is not installed"
    echo "install it with: sudo apt install lsof"
    return 127
  fi

  if ! lsof -nP -iTCP:"$1" -sTCP:LISTEN; then
    echo "no process is listening on port $1"
    return 1
  fi
}

# --- Linux & window path utilities ---

cpy_win_path() {
  # Learning bash experience
  # we could instead use built in tools like:
  # wslpath "C:\Users\..."  for win -> wsl
  # wslpath -w "/mnt/c/..." for wsl -> win
  if [ -z "$1" ]; then
    echo "usage: cpy_win_path <full window path>"
    return 1
  fi

  local path="${1//\\//}"
  path="${path,,}"

  echo "/mnt/${path//:/}"
}

# --- Sync documentation/obsidian shortcuts

# 1. Define colors globally so show_help can read them
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

show_help() {
  local cmd_name="$1"
  shift

  echo -e "${BOLD}Usage:${RESET} $cmd_name ${CYAN}<command>${RESET}\n"
  echo -e "${BOLD}Commands:${RESET}"

  while [ "$#" -gt 0 ]; do
    printf "  ${GREEN}%-12s${RESET} %s\n" "$1" "$2"
    shift 2
  done
}

sync_obs() {
  # git -C runs each command inside the vault without cd'ing, so the current
  # shell never leaves the directory it was in.
  local obsidian_dir="$HOME/work/documentation/central-vault"

  local usage=(
    "pull" "Pull notes from remote"
    "push" "Push notes to remote"
    "add" "Stage changes (default: all)"
    "commit" "Commit staged changes with a message"
    "status" "Show vault git status"
  )

  case "$1" in
  pull)
    echo "Pulling notes from remote ..."
    git -C "$obsidian_dir" pull origin
    ;;
  push)
    echo "Pushing notes to remote ..."
    git -C "$obsidian_dir" push origin
    ;;
  add)
    git -C "$obsidian_dir" add "${2:-.}"
    ;;
  commit)
    if [ -z "$2" ]; then
      echo "usage: sync_obs commit <message>"
      return 2
    fi
    git -C "$obsidian_dir" commit -m "$2"
    ;;
  status)
    git -C "$obsidian_dir" status
    ;;
  "")
    show_help "sync_obs" "${usage[@]}"
    return 1
    ;;
  *)
    echo -e "${RED}${BOLD}$1${RESET} is an unknown command"
    show_help "sync_obs" "${usage[@]}"
    return 1
    ;;
  esac
}

# --- Terraform Helpers ---
tfsummary() {
  local input
  if [ -t 0 ]; then
    input=$(terraform plan -no-color 2>&1) || {
      printf '%s\n' "$input" >&2
      return 1
    }
  else
    input=$(cat)
  fi

  printf '%s\n' "$input" |
    sed 's/\x1b\[[0-9;]*m//g' |
    grep -E '^\s*# .* (will be|must be)|^Plan:|^No changes'
}

# --- TMUX stuff
set_tmux_pane_title() {
  # Only do this inside tmux.
  [ -z "$TMUX" ] && return

  local dir="${PWD/#$HOME/~}"
  local base

  if [ "$dir" = "~" ]; then
    base="~"
  else
    base="${PWD##*/}"
  fi

  printf '\033]2;sh:%s\033\\' "$base"
}

# --- tmux-resurrect snapshot management ---
# tmux-resurrect saves a timestamped snapshot per save and points a `last`
# symlink at the newest one. `prefix + Ctrl-r` only ever restores `last`, and
# the plugin ships no way to browse or pick an older snapshot -- that's what
# this wraps.
_trs_dir() {
  # Honour @resurrect-dir if set, else mirror the plugin's own fallback logic
  # (legacy ~/.tmux/resurrect only if it already exists, XDG otherwise).
  local opt
  opt="$(tmux show-option -gqv @resurrect-dir 2>/dev/null)"
  if [ -n "$opt" ]; then
    echo "${opt/#\~/$HOME}"
  elif [ -d "$HOME/.tmux/resurrect" ]; then
    echo "$HOME/.tmux/resurrect"
  else
    echo "${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
  fi
}

# Newest first, so index 1 is always the most recent snapshot.
_trs_list() {
  local dir="$1"
  ls -1t "$dir"/tmux_resurrect_*.txt 2>/dev/null
}

trs() {
  local dir cmd
  dir="$(_trs_dir)"
  cmd="${1:-list}"

  case "$cmd" in
  list | ls)
    if [ ! -d "$dir" ]; then
      echo "no snapshots yet ($dir does not exist)"
      return 1
    fi

    local current
    current="$(readlink -f "$dir/last" 2>/dev/null)"

    local i=0 f
    printf '%-3s %-17s %-7s %-6s %s\n' "#" "SAVED" "WINDOWS" "PANES" "SESSIONS"
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      i=$((i + 1))

      # Filename carries the timestamp: tmux_resurrect_20260731T152735.txt
      local stamp base pretty wins panes sessions marker
      base="${f##*/}"
      stamp="${base#tmux_resurrect_}"
      stamp="${stamp%.txt}"
      pretty="${stamp:0:4}-${stamp:4:2}-${stamp:6:2} ${stamp:9:2}:${stamp:11:2}"

      wins="$(grep -c '^window' "$f")"
      panes="$(grep -c '^pane' "$f")"
      sessions="$(awk -F'\t' '$1=="pane"{print $2}' "$f" | sort -u | paste -sd, -)"

      marker=" "
      [ "$f" = "$current" ] && marker="*"

      printf '%s%-2s %-17s %-7s %-6s %s\n' \
        "$marker" "$i" "$pretty" "$wins" "$panes" "$sessions"
    done <<<"$(_trs_list "$dir")"

    if [ "$i" -eq 0 ]; then
      echo "(none)"
      return 1
    fi
    echo
    echo "* = what 'prefix + Ctrl-r' will restore. 'trs use N' to change it."
    ;;

  save)
    tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh
    sleep 1
    echo "saved -> $(readlink "$dir/last")"
    ;;

  use)
    # Repoint `last` so the next restore picks this snapshot instead.
    local n="$2" target
    if [ -z "$n" ]; then
      echo "usage: trs use N   (see 'trs list')" >&2
      return 2
    fi
    target="$(_trs_list "$dir" | sed -n "${n}p")"
    if [ -z "$target" ]; then
      echo "no snapshot #$n" >&2
      return 1
    fi
    ln -sf "${target##*/}" "$dir/last"
    echo "last -> ${target##*/}"
    ;;

  restore)
    [ -n "$2" ] && { trs use "$2" || return 1; }
    tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
    ;;

  rm)
    local n="$2" target
    if [ -z "$n" ]; then
      echo "usage: trs rm N" >&2
      return 2
    fi
    target="$(_trs_list "$dir" | sed -n "${n}p")"
    if [ -z "$target" ]; then
      echo "no snapshot #$n" >&2
      return 1
    fi
    rm -v "$target"
    ;;

  prune)
    # Keep the newest N (default 20); continuum's 15-min autosave piles up.
    local keep="${2:-20}" doomed
    doomed="$(_trs_list "$dir" | tail -n "+$((keep + 1))")"
    if [ -z "$doomed" ]; then
      echo "nothing to prune (keeping newest $keep)"
      return 0
    fi
    echo "$doomed" | xargs -r rm -v
    ;;

  *)
    cat <<'EOF'
trs - browse and manage tmux-resurrect snapshots

  trs [list]        list snapshots, newest first; * marks the restore target
  trs save          save the current session now
  trs use N         point `last` at snapshot N (prefix + Ctrl-r then uses it)
  trs restore [N]   restore now, optionally from snapshot N
  trs rm N          delete snapshot N
  trs prune [keep]  delete all but the newest `keep` snapshots (default 20)
EOF
    ;;
  esac
}

case "$PROMPT_COMMAND" in
*set_tmux_pane_title*) ;;
"")
  PROMPT_COMMAND="set_tmux_pane_title"
  ;;
*)
  PROMPT_COMMAND="set_tmux_pane_title; $PROMPT_COMMAND"
  ;;
esac

# superfile: cd to last visited directory on quit (pairs with cd_on_quit = true)
spf() {
    export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    command spf "$@"
    if [ -f "$SPF_LAST_DIR" ]; then
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    fi
}
