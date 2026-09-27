# zsh port of prompt.sh. Same layout:
#   [exit code] [user@host, over ssh] path (branch*+) >
# PROMPT is rebuilt in a precmd hook instead of using PROMPT_SUBST, so a
# branch name is never evaluated as shell code.

_set_prompt() {
  local exit_code=$?
  local p="" branch flags=""

  (( exit_code != 0 )) && p+="%F{red}${exit_code}%f "
  [[ -n "$SSH_CONNECTION" ]] && p+="%F{yellow}%n@%m%f "

  # Last 3 path components, with a leading ellipsis when truncated.
  # Bump the 4 to 5 if it truncates one level earlier than you like.
  p+="%F{blue}%(4~|…/%3~|%~)%f"

  branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    git rev-parse --short HEAD 2>/dev/null)"
  if [[ -n "$branch" ]]; then
    git diff --quiet --ignore-submodules -- 2>/dev/null || flags+="*"
    git diff --cached --quiet --ignore-submodules -- 2>/dev/null || flags+="+"
    # %% keeps a literal % in a branch name from being read as a prompt escape.
    p+=" %F{green}(${branch//\%/%%}%F{yellow}${flags}%F{green})%f"
  fi

  # '#' as root, '>' otherwise.
  p+=" %(!.#.>) "
  PROMPT="$p"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_prompt
