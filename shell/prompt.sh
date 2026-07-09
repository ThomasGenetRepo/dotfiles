parse_git_ref() {
  local ref

  ref="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" && {
    printf '%s' "$ref"
    return
  }

  ref="$(git rev-parse --short HEAD 2>/dev/null)" && {
    printf '%s' "$ref"
    return
  }
}

git_status_flags() {
  local flags=""

  if ! git diff --quiet --ignore-submodules -- 2>/dev/null; then
    flags+="*"
  fi

  if ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
    flags+="+"
  fi

  printf '%s' "$flags"
}

short_pwd() {
  local max=3
  local p

  case "$PWD" in
    "$HOME")
      printf '~'
      return
      ;;
    "$HOME"/*)
      p="~/${PWD#"$HOME"/}"
      ;;
    *)
      p="$PWD"
      ;;
  esac

  local prefix=""

  if [[ "$p" == "~/"* ]]; then
    prefix="~/"
    p="${p#"~/"}"
  elif [[ "$p" == /* ]]; then
    prefix="/"
    p="${p#/}"
  fi

  local IFS='/'
  local -a parts=()
  read -ra parts <<< "$p"

  if (( ${#parts[@]} > max )); then
    local start=$(( ${#parts[@]} - max ))
    printf '…'
    for (( i=start; i<${#parts[@]}; i++ )); do
      printf '/%s' "${parts[$i]}"
    done
  else
    printf '%s%s' "$prefix" "$p"
  fi
}

host_context() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    printf '%s@%s ' "$USER" "$(hostname -s)"
  fi
}

set_prompt() {
  local exit_code=$?
  local branch
  local flags
  local cwd
  local host

  branch="$(parse_git_ref)"
  flags="$(git_status_flags)"
  cwd="$(short_pwd)"
  host="$(host_context)"

  local blue='\[\033[34m\]'
  local green='\[\033[32m\]'
  local yellow='\[\033[33m\]'
  local red='\[\033[31m\]'
  local reset='\[\033[0m\]'

  PS1=""

  if (( exit_code != 0 )); then
    PS1+="${red}${exit_code}${reset} "
  fi

  if [[ -n "$host" ]]; then
    PS1+="${yellow}${host}${reset}"
  fi

  PS1+="${blue}${cwd}${reset}"

  if [[ -n "$branch" ]]; then
    PS1+=" ${green}(${branch}"

    if [[ -n "$flags" ]]; then
      PS1+="${yellow}${flags}${green}"
    fi

    PS1+=")${reset}"
  fi

  if [[ "$EUID" -eq 0 ]]; then
    PS1+=" # "
  else
    PS1+=" > "
  fi
}

PROMPT_COMMAND=set_prompt
