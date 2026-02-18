#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  CORVA_BEARER_TOKEN
  CORVA_DATA_API_BASE_URL
  CORVA_PROVIDER
  CORVA_COLLECTION
  CORVA_ASSET_ID
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required env var: $var" >&2
    exit 1
  fi
done

limit="${CORVA_LIMIT:-10}"
if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
  echo "CORVA_LIMIT must be an integer" >&2
  exit 1
fi

if (( limit < 5 || limit > 20 )); then
  echo "CORVA_LIMIT must be between 5 and 20 (current: $limit)" >&2
  exit 1
fi

base_url="${CORVA_DATA_API_BASE_URL%/}"
endpoint="$base_url/api/v1/data/${CORVA_PROVIDER}/${CORVA_COLLECTION}/"

asset_id="$CORVA_ASSET_ID"
if [[ "$asset_id" =~ ^[0-9]+$ ]]; then
  query_json="{\"asset_id\":$asset_id}"
else
  query_json="{\"asset_id\":\"$asset_id\"}"
fi

if [[ -n "${CORVA_QUERY:-}" ]]; then
  # Optional override for datasets that key by metadata.asset_id or other fields.
  query_json="$CORVA_QUERY"
fi

sort_json="${CORVA_SORT:-{\"timestamp\":-1}}"

curl_args=(
  --silent
  --show-error
  --fail
  --get
  "$endpoint"
  -H "Accept: application/json"
  -H "Authorization: Bearer ${CORVA_BEARER_TOKEN}"
  --data-urlencode "limit=$limit"
  --data-urlencode "skip=0"
  --data-urlencode "query=$query_json"
  --data-urlencode "sort=$sort_json"
)

if [[ -n "${CORVA_FIELDS:-}" ]]; then
  curl_args+=(--data-urlencode "fields=${CORVA_FIELDS}")
fi

curl "${curl_args[@]}"
printf '\n'
