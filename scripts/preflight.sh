#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh [options]

Options:
  --app-root <path>         App root directory (default: current directory)
  --strict                  Treat missing context/token as failures
  --asset-id <id>           Target asset id
  --provider <name>         Data provider (default: corva)
  --environment <qa|prod>   Runtime environment (default: prod)
  --goal-intent <text>      User goal in plain language
  --collection <name>       Resolved dataset collection
  --help                    Show this help
USAGE
}

APP_ROOT="$(pwd)"
STRICT=0
ASSET_ID=""
PROVIDER="corva"
ENVIRONMENT="prod"
GOAL_INTENT=""
COLLECTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-root)
      APP_ROOT="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --asset-id)
      ASSET_ID="$2"
      shift 2
      ;;
    --provider)
      PROVIDER="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --goal-intent)
      GOAL_INTENT="$2"
      shift 2
      ;;
    --collection)
      COLLECTION="$2"
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

passes=0
warnings=0
failures=0

pass() {
  echo "[pass] $1"
  passes=$((passes + 1))
}

warn() {
  echo "[warn] $1"
  warnings=$((warnings + 1))
}

fail() {
  echo "[fail] $1"
  failures=$((failures + 1))
}

context_check() {
  local label="$1"
  local value="$2"

  if [[ -n "$value" ]]; then
    pass "$label is set"
    return
  fi

  if [[ "$STRICT" -eq 1 ]]; then
    fail "$label is required in --strict mode"
  else
    warn "$label is not set (allowed in fast-start mode)"
  fi
}

if [[ ! -d "$APP_ROOT" ]]; then
  fail "app root does not exist: $APP_ROOT"
else
  pass "app root exists: $APP_ROOT"
fi

PACKAGE_JSON="$APP_ROOT/package.json"
if [[ -f "$PACKAGE_JSON" ]]; then
  pass "package.json found"

  if node -e 'const fs=require("fs"); const p=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); if(!(p.scripts && p.scripts.start)){process.exit(1)}' "$PACKAGE_JSON"; then
    pass "package.json has scripts.start"
  else
    fail "package.json is missing scripts.start"
  fi
else
  fail "package.json not found at $PACKAGE_JSON"
fi

if command -v yarn >/dev/null 2>&1; then
  pass "yarn command is available"
else
  warn "yarn command is not available"
fi

ENV_FILE="$APP_ROOT/.env.local"
TOKEN_PRESENT=0
if [[ -f "$ENV_FILE" ]]; then
  pass ".env.local found"

  file_mode=""
  if stat -f "%Lp" "$ENV_FILE" >/dev/null 2>&1; then
    file_mode="$(stat -f "%Lp" "$ENV_FILE")"
  elif stat -c "%a" "$ENV_FILE" >/dev/null 2>&1; then
    file_mode="$(stat -c "%a" "$ENV_FILE")"
  fi

  if [[ -n "$file_mode" ]]; then
    if [[ "$file_mode" == "600" || "$file_mode" == "400" ]]; then
      pass ".env.local permissions are restricted ($file_mode)"
    else
      if [[ "$STRICT" -eq 1 ]]; then
        fail ".env.local permissions should be 600 or 400 (current: $file_mode)"
      else
        warn ".env.local permissions should be 600 or 400 (current: $file_mode)"
      fi
    fi
  fi

  token_value="$(awk '
    /^[[:space:]]*CORVA_BEARER_TOKEN[[:space:]]*=/ {
      line=$0
      sub(/^[[:space:]]*CORVA_BEARER_TOKEN[[:space:]]*=[[:space:]]*/, "", line)
      sub(/[[:space:]]+$/, "", line)
      gsub(/^"|"$/, "", line)
      print line
      exit
    }
  ' "$ENV_FILE")"
  if [[ -n "$token_value" ]]; then
    TOKEN_PRESENT=1
    pass "CORVA_BEARER_TOKEN is present"
  else
    if [[ "$STRICT" -eq 1 ]]; then
      fail "CORVA_BEARER_TOKEN is missing in .env.local"
    else
      warn "CORVA_BEARER_TOKEN is missing in .env.local"
    fi
  fi
else
  if [[ "$STRICT" -eq 1 ]]; then
    fail ".env.local is required in --strict mode"
  else
    warn ".env.local not found (mock mode is still possible)"
  fi
fi

context_check "asset_id" "$ASSET_ID"
context_check "provider" "$PROVIDER"
context_check "environment" "$ENVIRONMENT"
context_check "goal_intent" "$GOAL_INTENT"
context_check "collection" "$COLLECTION"

if [[ "$STRICT" -eq 1 && "$TOKEN_PRESENT" -eq 0 ]]; then
  fail "strict mode cannot proceed without CORVA_BEARER_TOKEN"
fi

result="pass"
if [[ "$failures" -gt 0 ]]; then
  result="fail"
elif [[ "$warnings" -gt 0 ]]; then
  result="warn"
fi

echo "SUMMARY passes=$passes warnings=$warnings failures=$failures strict=$STRICT"
echo "RESULT=$result"
echo "APP_ROOT=$APP_ROOT"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

exit 0
