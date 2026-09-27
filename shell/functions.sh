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
    return 127
  fi

  if ! lsof -nP -iTCP:"$1" -sTCP:LISTEN; then
    echo "no process is listening on port $1"
    return 1
  fi
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

# superfile: cd to last visited directory on quit (pairs with cd_on_quit = true)
spf() {
  export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
  command spf "$@"
  if [ -f "$SPF_LAST_DIR" ]; then
    . "$SPF_LAST_DIR"
    rm -f -- "$SPF_LAST_DIR" >/dev/null
  fi
}
