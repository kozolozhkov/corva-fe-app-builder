# Data Sampling

Use this reference when wiring real data and validating schema confidence.

## Goal

Fetch a real sample for the target `provider` + `collection` + `asset_id`, then report what fields are actually available.

## Required Inputs

1. Data API base URL (`--base-url`)
2. `provider` (default `corva`)
3. `collection`
4. `asset_id` (or explicit query override)
5. Bearer token (from `<app-root>/.env.local` or `--token`)

## Preferred Script

Use `scripts/sample_data.js`.

Example:

```bash
<skill-root>/scripts/sample_data.js \
  --app-root <app-root> \
  --base-url <data_api_base_url> \
  --collection <collection> \
  --asset-id <asset_id> \
  --limit 10
```

Optional overrides:

- `--provider <provider>` only when you need a non-default provider (default is `corva`).
- `--query-field metadata.asset_id` when the dataset is keyed there.
- `--query-json '{"metadata.asset_id":123}'` for full custom query.
- `--sort-json '{"timestamp":-1}'` to control ordering.

## Reporting Contract (required when samples are fetched)

Report field availability in a field-by-field format:

1. Flattened field path
2. Meaning in plain language
3. Meaning confidence: `documented` or `inferred`
4. Presence ratio
5. Inferred type(s)
6. Nullability
7. Optional safe example value

If meaning is not explicitly documented, mark it as `inferred`.

## No-Data Handling (mandatory)

If sample fetch returns zero records, explicitly state:

`No data was found for this collection and asset in the selected environment.`

Also state that downstream field mapping is provisional until data appears.

## Query Shape Guardrails

1. Default Data API query shape: `query={"asset_id": <id>}` with explicit `sort` + `limit`.
2. Confirm whether the target dataset uses `asset_id` or alternate keying (for example `metadata.asset_id`).
3. Keep client-to-endpoint mapping aligned with `references/client_method_to_endpoint_map.md`.
4. Prefer `corvaDataAPI` for `/api/v1/data/...` calls.

## Fallback Scripts

If `sample_data.js` cannot be used in the current environment:

1. Fetch with `scripts/fetch_samples_with_env_token.sh`.
2. Summarize fields with `scripts/infer_field_presence.js`.
