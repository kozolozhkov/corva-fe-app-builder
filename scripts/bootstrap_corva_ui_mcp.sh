#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bootstrap_corva_ui_mcp.sh [options]

Options:
  --workspace <path>   Workspace root containing node_modules (default: current directory)
  --skip-setup         Skip running npx setup helper
  --help               Show this help
USAGE
}

WORKSPACE="$(pwd)"
SKIP_SETUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      WORKSPACE="$2"
      shift 2
      ;;
    --skip-setup)
      SKIP_SETUP=1
      shift
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

if [[ ! -d "$WORKSPACE" ]]; then
  echo "Workspace does not exist: $WORKSPACE" >&2
  exit 1
fi

if [[ "$SKIP_SETUP" -eq 0 ]]; then
  if ! command -v npx >/dev/null 2>&1; then
    echo "npx is required for initial Corva MCP setup" >&2
    exit 1
  fi

  (
    cd "$WORKSPACE"
    npx -p @corva/ui corva-ui-mcp-setup || true
  )
fi

MCP_BIN="$WORKSPACE/node_modules/.bin/corva-ui-mcp"
if [[ ! -x "$MCP_BIN" ]]; then
  echo "Missing executable MCP binary: $MCP_BIN" >&2
  echo "Install @corva/ui in workspace and rerun." >&2
  exit 1
fi

update_json_file() {
  local file_path="$1"

  mkdir -p "$(dirname "$file_path")"

  MCP_CONFIG_FILE="$file_path" MCP_CONFIG_CMD="$MCP_BIN" node <<'NODE'
const fs = require('fs');

const filePath = process.env.MCP_CONFIG_FILE;
const command = process.env.MCP_CONFIG_CMD;

let data = {};
if (fs.existsSync(filePath)) {
  try {
    data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    throw new Error(`Invalid JSON in ${filePath}: ${error.message}`);
  }
}

if (!data || typeof data !== 'object') {
  data = {};
}

if (!data.mcpServers || typeof data.mcpServers !== 'object') {
  data.mcpServers = {};
}

data.mcpServers['corva-ui'] = {
  command,
};

fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`);
NODE
}

update_json_file "$WORKSPACE/.mcp.json"
update_json_file "$WORKSPACE/.cursor/mcp.json"

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_CONFIG="$CODEX_HOME_DIR/config.toml"
mkdir -p "$CODEX_HOME_DIR"

if [[ ! -f "$CODEX_CONFIG" ]]; then
  cat > "$CODEX_CONFIG" <<CFG
[mcp_servers.corva_ui]
command = "$MCP_BIN"
CFG
else
  if grep -q "^\[mcp_servers\.corva_ui\]" "$CODEX_CONFIG"; then
    awk -v new_cmd="$MCP_BIN" '
      BEGIN { in_section = 0; replaced = 0 }
      /^\[mcp_servers\.corva_ui\]/ {
        in_section = 1
        print
        next
      }
      /^\[/ {
        if (in_section && replaced == 0) {
          print "command = \"" new_cmd "\""
          replaced = 1
        }
        in_section = 0
        print
        next
      }
      {
        if (in_section && $0 ~ /^command[[:space:]]*=/) {
          if (replaced == 0) {
            print "command = \"" new_cmd "\""
            replaced = 1
          }
          next
        }
        print
      }
      END {
        if (in_section && replaced == 0) {
          print "command = \"" new_cmd "\""
        }
      }
    ' "$CODEX_CONFIG" > "$CODEX_CONFIG.tmp"
    mv "$CODEX_CONFIG.tmp" "$CODEX_CONFIG"
  else
    cat >> "$CODEX_CONFIG" <<CFG

[mcp_servers.corva_ui]
command = "$MCP_BIN"
CFG
  fi
fi

echo "UPDATED_WORKSPACE_MCP_JSON=$WORKSPACE/.mcp.json"
echo "UPDATED_CURSOR_MCP_JSON=$WORKSPACE/.cursor/mcp.json"
echo "UPDATED_CODEX_CONFIG=$CODEX_CONFIG"
echo "MCP_COMMAND=$MCP_BIN"
echo "RESTART_REQUIRED=true"
