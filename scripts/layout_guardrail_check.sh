#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  layout_guardrail_check.sh [options]

Options:
  --app-root <path>   App root directory (default: current directory)
  --app-file <path>   Relative app component file (default: src/App.tsx)
  --css-file <path>   Relative css file (default: src/App.css)
  --help              Show this help
USAGE
}

APP_ROOT="$(pwd)"
APP_FILE="src/App.tsx"
CSS_FILE="src/App.css"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-root)
      APP_ROOT="$2"
      shift 2
      ;;
    --app-file)
      APP_FILE="$2"
      shift 2
      ;;
    --css-file)
      CSS_FILE="$2"
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

APP_PATH="$APP_ROOT/$APP_FILE"
CSS_PATH="$APP_ROOT/$CSS_FILE"

passes=0
failures=0

pass() {
  echo "[pass] $1"
  passes=$((passes + 1))
}

fail() {
  echo "[fail] $1"
  failures=$((failures + 1))
}

if [[ ! -f "$APP_PATH" ]]; then
  fail "app file not found: $APP_PATH"
  echo "SUMMARY passes=$passes failures=$failures"
  exit 1
fi

if [[ ! -f "$CSS_PATH" ]]; then
  fail "css file not found: $CSS_PATH"
  echo "SUMMARY passes=$passes failures=$failures"
  exit 1
fi

if rg -q 'elementsClassNames\s*=\s*\{[^}]*content\s*:\s*styles\.[A-Za-z0-9_]+' "$APP_PATH"; then
  pass "AppContainer content scroll owner is configured via elementsClassNames.content"
else
  fail "AppContainer is missing elementsClassNames.content mapping to a css class"
fi

if rg -q 'overflow-y\s*:\s*auto\s*;' "$CSS_PATH"; then
  pass "css contains overflow-y:auto"
else
  fail "css is missing overflow-y:auto for active scroll container"
fi

if rg -q 'min-height\s*:\s*0\s*;' "$CSS_PATH"; then
  pass "css contains min-height:0"
else
  fail "css is missing min-height:0 for active scroll container"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "SUMMARY passes=$passes failures=$failures"
  echo "RESULT=fail"
  exit 1
fi

echo "SUMMARY passes=$passes failures=$failures"
echo "RESULT=pass"
exit 0
