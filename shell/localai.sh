# localai - lightweight local AI service manager
#
# Commands:
#   localai up
#   localai down
#   localai restart
#   localai ensure
#   localai status        (includes telemetry: aitel status --brief)
#   localai stats [--since 30d]     telemetry digest (aitel summary)
#   localai stats <report> [...]    any aitel report: tools, models, session <id>, ...
#
#   localai logs
#   localai logs [service ...]
#   localai logs -n N [service ...]
#   localai logs -f [-n N] [service ...]
#   localai logs size [service ...]
#   localai logs prune [--days N] [service ...]
#   localai logs prune --all [service ...]
#
# v1 services:
#   mtplx
#
# Expected environment variables:
#
#   LOCALAI_SESSION
#   LOCALAI_STATE_DIR
#
#   LOCALAI_MTPLX_MODEL
#   LOCALAI_MTPLX_HOST
#   LOCALAI_MTPLX_PORT
#   LOCALAI_MTPLX_KV
#   LOCALAI_MTPLX_SSD_CACHE
#
#   LOCALAI_START_TIMEOUT
#   LOCALAI_LOG_RETENTION_DAYS

typeset -ga _LOCALAI_SERVICES=(mtplx)

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

_localai_require() {
  local command_name

  for command_name in tmux curl mtplx; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      echo "localai: required command not found: $command_name" >&2
      return 1
    fi
  done
}

# ------------------------------------------------------------------------------
# State / logs
# ------------------------------------------------------------------------------

_localai_state_init() {
  mkdir -p "$LOCALAI_STATE_DIR/logs"
}

_localai_log_dir() {
  local service="$1"

  case "$service" in
    mtplx)
      echo "$LOCALAI_STATE_DIR/logs/mtplx"
      ;;
    *)
      echo "localai: unknown service: $service" >&2
      return 1
      ;;
  esac
}

_localai_log_path() {
  local service="$1"
  local log_dir

  log_dir="$(_localai_log_dir "$service")" || return 1

  mkdir -p "$log_dir"

  echo "$log_dir/$(date '+%Y-%m-%d').log"
}

_localai_log_files() {
  local service="$1"
  local log_dir

  log_dir="$(_localai_log_dir "$service")" || return 1

  [[ -d "$log_dir" ]] || return 0

  find "$log_dir" \
    -type f \
    -name '*.log' \
    -print 2>/dev/null |
    sort
}

_localai_human_kb() {
  local kb="$1"

  if (( kb >= 1048576 )); then
    printf "%.1fG" "$(( kb / 1048576.0 ))"
  elif (( kb >= 1024 )); then
    printf "%.1fM" "$(( kb / 1024.0 ))"
  else
    printf "%dK" "$kb"
  fi
}

# ------------------------------------------------------------------------------
# tmux
# ------------------------------------------------------------------------------

_localai_session_exists() {
  tmux has-session -t "$LOCALAI_SESSION" 2>/dev/null
}

_localai_window_exists() {
  local service="$1"

  _localai_session_exists || return 1

  tmux list-windows \
    -t "$LOCALAI_SESSION" \
    -F '#{window_name}' 2>/dev/null |
    grep -Fxq "$service"
}

_localai_start_window() {
  local service="$1"

  if _localai_window_exists "$service"; then
    return 0
  fi

  if _localai_session_exists; then
    tmux new-window \
      -d \
      -t "$LOCALAI_SESSION" \
      -n "$service"
  else
    tmux new-session \
      -d \
      -s "$LOCALAI_SESSION" \
      -n "$service"
  fi
}

# ------------------------------------------------------------------------------
# MTPLX
# ------------------------------------------------------------------------------

_localai_mtplx_healthy() {
  curl \
    --silent \
    --fail \
    --max-time 1 \
    "http://${LOCALAI_MTPLX_HOST}:${LOCALAI_MTPLX_PORT}/health" \
    >/dev/null 2>&1
}

_localai_mtplx_managed() {
  _localai_window_exists mtplx
}

_localai_mtplx_external() {
  _localai_mtplx_healthy && ! _localai_mtplx_managed
}

_localai_wait_mtplx() {
  local elapsed=0

  while (( elapsed < LOCALAI_START_TIMEOUT )); do
    if _localai_mtplx_healthy; then
      echo "  mtplx  healthy"
      return 0
    fi

    sleep 1
    (( elapsed++ ))
  done

  echo "localai: MTPLX failed to become healthy after ${LOCALAI_START_TIMEOUT}s." >&2
  echo "localai: inspect with: localai logs -n 100 mtplx" >&2

  return 1
}

_localai_start_mtplx() {
  local log_path
  local start_command

  log_path="$(_localai_log_path mtplx)" || return 1

  if _localai_mtplx_healthy; then
    if _localai_mtplx_managed; then
      echo "  mtplx  healthy"
      return 0
    fi

    echo "localai: MTPLX is already healthy but is not managed by localai." >&2
    echo "localai: stop the existing server before running 'localai up'." >&2

    return 1
  fi

  if _localai_mtplx_managed; then
    echo "  mtplx  starting/unhealthy, waiting..."
    _localai_wait_mtplx
    return $?
  fi

  _localai_start_window mtplx || return 1

  printf '\n===== localai start %s =====\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_path"

  start_command="mtplx serve \
--model ${(q)LOCALAI_MTPLX_MODEL} \
--host ${(q)LOCALAI_MTPLX_HOST} \
--port ${(q)LOCALAI_MTPLX_PORT} \
--paged-kv-quantization ${(q)LOCALAI_MTPLX_KV} \
--ssd-session-cache ${(q)LOCALAI_MTPLX_SSD_CACHE} \
2>&1 | tee -a ${(q)log_path}"

  tmux send-keys \
    -t "$LOCALAI_SESSION:mtplx" \
    "$start_command" \
    C-m

  echo "  mtplx  starting..."

  _localai_wait_mtplx
}

# ------------------------------------------------------------------------------
# Stack lifecycle
# ------------------------------------------------------------------------------

_localai_up() {
  _localai_require || return 1
  _localai_state_init || return 1

  if _localai_mtplx_external; then
    echo "localai: MTPLX is already running outside the localai tmux session." >&2
    echo "localai: stop it first, then run 'localai up'." >&2

    return 1
  fi

  if _localai_mtplx_managed && _localai_mtplx_healthy; then
    echo "localai: already running"
    echo "  mtplx  healthy"

    return 0
  fi

  echo "localai: starting"

  _localai_start_mtplx || return 1

  echo "localai: ready"
}

_localai_down() {
  _localai_require || return 1

  if ! _localai_session_exists; then
    echo "localai: already stopped"

    if _localai_mtplx_healthy; then
      echo "  mtplx  healthy, but externally managed"
    fi

    return 0
  fi

  echo "localai: stopping"

  tmux kill-session -t "$LOCALAI_SESSION"

  local elapsed=0

  while _localai_mtplx_healthy && (( elapsed < 10 )); do
    sleep 1
    (( elapsed++ ))
  done

  if _localai_mtplx_healthy; then
    echo "localai: tmux session stopped, but MTPLX is still responding." >&2
    return 1
  fi

  echo "localai: stopped"
}

_localai_restart() {
  _localai_down || return 1
  _localai_up
}

_localai_ensure() {
  _localai_require || return 1
  _localai_state_init || return 1

  if _localai_mtplx_managed && _localai_mtplx_healthy; then
    return 0
  fi

  if _localai_mtplx_external; then
    echo "localai: MTPLX is healthy but is not managed by localai." >&2
    return 1
  fi

  if _localai_mtplx_managed; then
    echo "localai: MTPLX is managed but unhealthy." >&2
    echo "localai: inspect with 'localai logs -n 100 mtplx' or run 'localai restart'." >&2

    return 1
  fi

  _localai_up
}

# ------------------------------------------------------------------------------
# Status
# ------------------------------------------------------------------------------

_localai_status() {
  _localai_require || return 1

  echo "localai"

  if _localai_session_exists; then
    echo "  tmux     running"
  else
    echo "  tmux     stopped"
  fi

  if _localai_mtplx_managed; then
    if _localai_mtplx_healthy; then
      echo "  mtplx    healthy"
    else
      echo "  mtplx    unhealthy"
    fi
  elif _localai_mtplx_healthy; then
    echo "  mtplx    healthy (external)"
  else
    echo "  mtplx    stopped"
  fi

  echo "  model    $LOCALAI_MTPLX_MODEL"
  echo "  kv       $LOCALAI_MTPLX_KV"
  echo "  endpoint http://${LOCALAI_MTPLX_HOST}:${LOCALAI_MTPLX_PORT}"
  echo "  logs     $LOCALAI_STATE_DIR/logs"

  _localai_telemetry_status

  # Telemetry problems are reported above but don't fail status.
  _localai_mtplx_managed && _localai_mtplx_healthy
}

# Telemetry is aitel (~/local_ai/telemetry); it prints its own status line.
_localai_telemetry_status() {
  if ! command -v aitel >/dev/null 2>&1; then
    echo "  telemetry not installed (make -C ~/local_ai/telemetry install)"
    return 0
  fi

  aitel status --brief
}

# localai stats              -> aitel summary (last 7d vs prior 7d)
# localai stats --since 30d  -> aitel summary --since 30d
# localai stats <report> ... -> aitel <report> ...  (tools, models, session <id>, ...)
_localai_stats() {
  if ! command -v aitel >/dev/null 2>&1; then
    echo "localai: telemetry not installed (make -C ~/local_ai/telemetry install)" >&2
    return 1
  fi

  if (( $# == 0 )) || [[ "$1" == -* && "$1" != "-h" && "$1" != "--help" ]]; then
    aitel summary "$@"
  else
    aitel "$@"
  fi
}

# ------------------------------------------------------------------------------
# Service validation
# ------------------------------------------------------------------------------

_localai_validate_service() {
  local candidate="$1"
  local service

  for service in "${_LOCALAI_SERVICES[@]}"; do
    if [[ "$candidate" == "$service" ]]; then
      return 0
    fi
  done

  echo "localai: unknown service: $candidate" >&2
  echo "localai: available services: ${_LOCALAI_SERVICES[*]}" >&2

  return 1
}

# ------------------------------------------------------------------------------
# Logs
# ------------------------------------------------------------------------------

_localai_logs() {
  _localai_state_init || return 1

  local follow=0
  local lines=""
  local action="show"
  local prune_days="${LOCALAI_LOG_RETENTION_DAYS:-14}"
  local prune_all=0

  local -a services=()

  if (( $# > 0 )); then
    case "$1" in
      size)
        action="size"
        shift
        ;;
      prune)
        action="prune"
        shift
        ;;
    esac
  fi

  while (( $# > 0 )); do
    case "$1" in
      -f|--follow)
        follow=1
        ;;

      -n|--lines)
        shift

        if (( $# == 0 )); then
          echo "localai: -n/--lines requires a number" >&2
          return 2
        fi

        if [[ ! "$1" =~ '^[0-9]+$' ]]; then
          echo "localai: invalid line count: $1" >&2
          return 2
        fi

        lines="$1"
        ;;

      --days)
        shift

        if (( $# == 0 )); then
          echo "localai: --days requires a number" >&2
          return 2
        fi

        if [[ ! "$1" =~ '^[0-9]+$' ]]; then
          echo "localai: invalid retention days: $1" >&2
          return 2
        fi

        if (( "$1" < 1 )); then
          echo "localai: retention days must be at least 1; use --all to remove everything" >&2
          return 2
        fi

        prune_days="$1"
        ;;

      --all)
        prune_all=1
        ;;

      -h|--help)
        cat <<EOF
usage:
  localai logs [-f|--follow] [-n|--lines N] [service ...]
  localai logs size [service ...]
  localai logs prune [--days N|--all] [service ...]

services:
  ${_LOCALAI_SERVICES[*]}

default retention:
  ${LOCALAI_LOG_RETENTION_DAYS:-14} days
EOF
        return 0
        ;;

      --)
        shift
        services+=("$@")
        break
        ;;

      -*)
        echo "localai: unknown logs option: $1" >&2
        return 2
        ;;

      *)
        services+=("$1")
        ;;
    esac

    shift
  done

  if (( ${#services[@]} == 0 )); then
    services=("${_LOCALAI_SERVICES[@]}")
  fi

  local service
  local log_dir
  local log_path
  local size_kb

  for service in "${services[@]}"; do
    _localai_validate_service "$service" || return 2
  done

  case "$action" in
    size)
      local total_kb=0

      echo "localai logs"
      echo

      for service in "${services[@]}"; do
        log_dir="$(_localai_log_dir "$service")" || return 2

        if [[ -d "$log_dir" ]]; then
          size_kb="$(du -sk "$log_dir" 2>/dev/null | awk '{print $1}')"
          size_kb="${size_kb:-0}"
        else
          size_kb=0
        fi

        (( total_kb += size_kb ))

        printf "  %-12s " "$service"
        _localai_human_kb "$size_kb"
        echo
      done

      echo "  ----------------"

      printf "  %-12s " "total"
      _localai_human_kb "$total_kb"
      echo

      return 0
      ;;

    prune)
      for service in "${services[@]}"; do
        log_dir="$(_localai_log_dir "$service")" || return 2

        [[ -d "$log_dir" ]] || continue

        if (( prune_all )); then
          find "$log_dir" \
            -type f \
            -name '*.log' \
            -delete

          echo "  $service  pruned all logs"
        else
          find "$log_dir" \
            -type f \
            -name '*.log' \
            -mtime +"$prune_days" \
            -delete

          echo "  $service  retained last ${prune_days} days"
        fi
      done

      return 0
      ;;
  esac

  # Follow mode only follows today's log files.
  if (( follow )); then
    local -a current_paths=()

    for service in "${services[@]}"; do
      log_path="$(_localai_log_path "$service")" || return 2

      [[ -e "$log_path" ]] || touch "$log_path"

      current_paths+=("$log_path")
    done

    if [[ -n "$lines" ]]; then
      tail -n "$lines" -F "${current_paths[@]}"
    else
      tail -F "${current_paths[@]}"
    fi

    return
  fi

  # Non-follow mode reads all retained daily files.
  for service in "${services[@]}"; do
    echo "===== $service ====="

    local -a service_files=()
    service_files=("${(@f)$(_localai_log_files "$service")}")

    if (( ${#service_files[@]} == 0 )); then
      echo "(no logs)"
      echo
      continue
    fi

    if [[ -n "$lines" ]]; then
      cat "${service_files[@]}" | tail -n "$lines"
    else
      cat "${service_files[@]}"
    fi

    echo
  done
}

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

_localai_help() {
  cat <<'EOF'
usage: localai <command>

commands:
  up
      Start missing services.

  down
      Stop the localai stack.

  restart
      Restart the stack.

  ensure
      Ensure the stack is running and healthy.

  status
      Show service status, including telemetry.

  stats [--since 30d]
      Telemetry digest: usage, model speed vs the prior window,
      failures, tools, MCP servers, and flags.

  stats <report> [flags]
      Run an aitel report: tools, errors, models, sessions,
      session <id>, setups, sql "<query>". See 'aitel help'.

  logs
      Print all retained service logs.

  logs [services...]
      Print logs for selected services.

  logs -n N [services...]
      Print the last N lines.

  logs -f [services...]
      Follow current log files.

  logs -f -n N [services...]
      Print the last N lines and continue following.

  logs size [services...]
      Show persisted log disk usage.

  logs prune [services...]
      Apply the default retention period.

  logs prune --days N [services...]
      Retain the requested number of days.

  logs prune --all [services...]
      Remove all persisted logs.

examples:
  localai up
  localai status

  localai stats
  localai stats --since 30d
  localai stats tools --all
  localai stats session 4536

  localai logs
  localai logs mtplx
  localai logs -n 100
  localai logs -n 100 mtplx
  localai logs -f
  localai logs -f -n 50 mtplx

  localai logs size
  localai logs size mtplx

  localai logs prune
  localai logs prune --days 7
  localai logs prune --all

  localai restart
  localai down
EOF
}

# ------------------------------------------------------------------------------
# Public dispatcher
# ------------------------------------------------------------------------------

localai() {
  case "${1:-}" in
    up)
      shift
      _localai_up "$@"
      ;;

    down)
      shift
      _localai_down "$@"
      ;;

    restart)
      shift
      _localai_restart "$@"
      ;;

    ensure)
      shift
      _localai_ensure "$@"
      ;;

    status)
      shift
      _localai_status "$@"
      ;;

    stats)
      shift
      _localai_stats "$@"
      ;;

    logs)
      shift
      _localai_logs "$@"
      ;;

    help|-h|--help|"")
      _localai_help
      ;;

    *)
      echo "localai: unknown command: $1" >&2
      echo "run 'localai help' for usage" >&2
      return 2
      ;;
  esac
}
