#!/usr/bin/env bash
set -euo pipefail

ROUTER_FILE="${1:-/Users/kzolozhkov/corva/core/data-api/app/api/v1/router.py}"
DATA_FILE="${2:-/Users/kzolozhkov/corva/core/data-api/app/api/v1/data.py}"
DATASET_FILE="${3:-/Users/kzolozhkov/corva/core/data-api/app/api/v1/dataset.py}"
BASE_PREFIX="${CORVA_DATA_API_PREFIX:-/api/v1}"

for file in "$ROUTER_FILE" "$DATA_FILE" "$DATASET_FILE"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing file: $file" >&2
    exit 1
  fi
done

data_prefix="$(sed -nE 's/.*include_router\(data\.router, prefix="([^"]+)"\).*/\1/p' "$ROUTER_FILE" | head -n1)"
dataset_prefix="$(sed -nE 's/.*include_router\(dataset\.router, prefix="([^"]+)"\).*/\1/p' "$ROUTER_FILE" | head -n1)"

[[ -z "$data_prefix" ]] && data_prefix="/data"
[[ -z "$dataset_prefix" ]] && dataset_prefix="/dataset"

extract_gets() {
  local file="$1"
  local route_prefix="$2"

  awk -v base_prefix="$BASE_PREFIX" -v route_prefix="$route_prefix" -v src_file="$file" '
    function normalize(path) {
      gsub(/\/+/,"/",path)
      return path
    }

    function emit() {
      if (route_path == "") {
        return
      }
      full = normalize(base_prefix route_prefix route_path)
      note = route_summary == "" ? "-" : route_summary
      printf "GET\t%s\t%s:%d\t%s\n", full, src_file, decorator_line, note
    }

    {
      line = $0

      if (line ~ /@router\.get\(/) {
        in_get = 1
        route_path = ""
        route_summary = ""
        decorator_line = NR
      }

      if (in_get) {
        if (route_path == "" && match(line, /"[^\"]+"/)) {
          route_path = substr(line, RSTART + 1, RLENGTH - 2)
        }

        if (route_summary == "" && match(line, /summary="[^\"]+"/)) {
          route_summary = substr(line, RSTART, RLENGTH)
          sub(/^summary="/, "", route_summary)
          sub(/"$/, "", route_summary)
        }

        if (line ~ /\)/) {
          emit()
          in_get = 0
        }
      }
    }
  ' "$file"
}

{
  extract_gets "$DATA_FILE" "$data_prefix"
  extract_gets "$DATASET_FILE" "$dataset_prefix"
} | awk 'BEGIN { OFS="\t" } !seen[$1 FS $2]++ { print }' | sort -t $'\t' -k2,2
