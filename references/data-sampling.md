# Data Sampling

Use this reference for real-data-first schema validation and reporting.

## Goal

Fetch real samples for the target `provider` + `collection` + `asset_id`, then report field availability and confidence.

## Required Inputs

1. Data API base URL (`--base-url`)
2. `provider` (default `corva`)
3. `collection`
4. `asset_id` (or explicit query override)
5. Bearer token from `<app-root>/.env.local` (or pre-exported `CORVA_BEARER_TOKEN` in local shell)

## Sampling Trigger (real-data-first)

Sampling is required before final field mapping whenever both conditions are true:

1. `asset_id` is known.
2. `CORVA_BEARER_TOKEN` is available in local environment.

## Preferred Script

Use `scripts/sample_data.js`.

```bash
<skill-root>/scripts/sample_data.js \
  --app-root <app-root> \
  --base-url <data_api_base_url> \
  --collection <collection> \
  --asset-id <asset_id> \
  --limit 10
```

Optional overrides:

- `--provider <provider>` when non-default provider is required.
- `--query-field metadata.asset_id` when the dataset is keyed there.
- `--query-json '{"metadata.asset_id":123}'` for full custom query.
- `--sort-json '{"timestamp":-1}'` to control ordering.

## Security Rule

1. Never ask user to paste token values in chat.
2. Ask user to set/update `.env.local` locally and reply `ready`.

## Fallback Branches (explicit)

1. Missing `asset_id`:
- skip sampling.
- continue with inferred mapping from dataset definitions.
- explicitly state: `Field mapping is inferred because asset_id is missing; providing asset_id will improve accuracy and smoother development.`
2. Missing token:
- skip sampling.
- continue with inferred mapping.
- explicitly state: `Real data sampling is unavailable because CORVA_BEARER_TOKEN is not set in .env.local.`
3. No-data sample:
- explicitly state: `No data was found for this collection and asset in the selected environment.`
- continue with inferred mapping and call schema confidence provisional.

## Reporting Contract (required)

When samples are fetched, report field availability in field-by-field format:

1. Flattened field path
2. Meaning in plain language
3. Meaning confidence: `documented` or `inferred`
4. Presence ratio
5. Inferred type(s)
6. Nullability
7. Optional safe example value

If meaning is not documented, mark as `inferred`.

## Query Shape Guardrails

1. Default Data API query shape: `query={"asset_id": <id>}` with explicit `sort` + `limit`.
2. Confirm whether dataset uses `asset_id` or alternate keying (for example `metadata.asset_id`).
3. Keep client-to-endpoint mapping aligned with `references/client_method_to_endpoint_map.md`.
4. Prefer `corvaDataAPI` for `/api/v1/data/...` calls.

## Fallback Scripts

If `sample_data.js` cannot be used:

1. Fetch with `scripts/fetch_samples_with_env_token.sh`.
2. Summarize fields with `scripts/infer_field_presence.js`.
