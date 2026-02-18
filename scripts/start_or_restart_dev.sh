#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  start_or_restart_dev.sh [options]

Options:
  --app-root <path>   App root directory (default: current directory)
  --url <url>         Expected app URL (default: http://localhost:3000)
  --timeout <seconds> Wait timeout for server startup (default: 120)
  --log-file <path>   Startup log path (default: <app-root>/.codex-devserver.log)
  --pid-file <path>   PID file path (default: <app-root>/.codex-devserver.pid)
  --help              Show this help
USAGE
}

APP_ROOT="$(pwd)"
URL="http://localhost:3000"
TIMEOUT=120
LOG_FILE=""
PID_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-root)
      APP_ROOT="$2"
      shift 2
      ;;
    --url)
      URL="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --log-file)
      LOG_FILE="$2"
      shift 2
      ;;
    --pid-file)
      PID_FILE="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! "$TIMEOUT" =~ ^[0-9]+$ ]]; then
  echo "--timeout must be a positive integer" >&2
  exit 1
fi

if [[ -z "$LOG_FILE" ]]; then
  LOG_FILE="$APP_ROOT/.codex-devserver.log"
fi
if [[ -z "$PID_FILE" ]]; then
  PID_FILE="$APP_ROOT/.codex-devserver.pid"
fi

if [[ ! -d "$APP_ROOT" ]]; then
  echo "App root does not exist: $APP_ROOT" >&2
  exit 1
fi

if [[ ! -f "$APP_ROOT/package.json" ]]; then
  echo "package.json not found in app root: $APP_ROOT" >&2
  exit 1
fi

if ! command -v yarn >/dev/null 2>&1; then
  echo "yarn is not available in PATH" >&2
  exit 1
fi

is_url_up() {
  local target_url="$1"
  curl --silent --show-error --fail --max-time 2 "$target_url" >/dev/null 2>&1
}

extract_url_from_log() {
  if [[ ! -f "$LOG_FILE" ]]; then
    return
  fi

  if command -v rg >/dev/null 2>&1; then
    rg -o 'https?://(localhost|127\.0\.0\.1):[0-9]+' "$LOG_FILE" | tail -n1 || true
  else
    grep -Eo 'https?://(localhost|127\.0\.0\.1):[0-9]+' "$LOG_FILE" | tail -n1 || true
  fi
}

known_url="$URL"
logged_url="$(extract_url_from_log)"
if [[ -n "$logged_url" ]]; then
  known_url="$logged_url"
fi

if is_url_up "$known_url"; then
  echo "STATUS=running"
  echo "URL=$known_url"
  echo "LOG_FILE=$LOG_FILE"
  if [[ -f "$PID_FILE" ]]; then
    echo "PID_FILE=$PID_FILE"
  fi
  exit 0
fi

if [[ -f "$PID_FILE" ]]; then
  old_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ "$old_pid" =~ ^[0-9]+$ ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" 2>/dev/null || true
    sleep 2
    if kill -0 "$old_pid" 2>/dev/null; then
      kill -9 "$old_pid" 2>/dev/null || true
    fi
  fi
  rm -f "$PID_FILE"
fi

mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"

(
  cd "$APP_ROOT"
  nohup yarn start >>"$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
)

new_pid="$(cat "$PID_FILE")"
if [[ ! "$new_pid" =~ ^[0-9]+$ ]]; then
  echo "Failed to start dev server: PID file is invalid" >&2
  exit 1
fi

deadline=$((SECONDS + TIMEOUT))
active_url="$URL"
started=0

while (( SECONDS < deadline )); do
  if ! kill -0 "$new_pid" 2>/dev/null; then
    echo "Dev server process exited early (pid: $new_pid)" >&2
    tail -n 80 "$LOG_FILE" >&2 || true
    exit 1
  fi

  discovered_url="$(extract_url_from_log)"
  if [[ -n "$discovered_url" ]]; then
    active_url="$discovered_url"
  fi

  if is_url_up "$active_url"; then
    started=1
    break
  fi

  sleep 2
done

if [[ "$started" -ne 1 ]]; then
  echo "Dev server did not become healthy within ${TIMEOUT}s" >&2
  tail -n 120 "$LOG_FILE" >&2 || true
  exit 1
fi

echo "STATUS=restarted"
echo "URL=$active_url"
echo "PID=$new_pid"
echo "PID_FILE=$PID_FILE"
echo "LOG_FILE=$LOG_FILE"
