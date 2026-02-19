# Sampling Fallback Branch (Inferred)

Use this branch whenever real sampling cannot run yet (missing `asset_id`, missing token, or no-data sample).

## Source Files

- `<skill-root>/references/dataset_descriptions/datasets.json`
- `<skill-root>/scripts/fetch_samples_with_env_token.sh`
- `<skill-root>/scripts/infer_field_presence.js`

## Trigger Conditions

Enter fallback when any condition is true:

1. `asset_id` is missing.
2. `CORVA_BEARER_TOKEN` is missing in `.env.local`.
3. Real sample request returns no records.

## Fallback Behavior Contract

1. Continue scaffolding/codegen with inferred field mapping.
2. Mark schema confidence as `inferred`.
3. Provide one next unblock question (`asset_id` or token setup).
4. Explain that real sampling will replace inferred mapping once context is available.

## Local Token Setup (no chat token sharing)

Put token in `<app-root>/.env.local`.

If the file is missing, provide local-only helper:

```bash
touch <app-root>/.env.local
chmod 600 <app-root>/.env.local
# Add CORVA_BEARER_TOKEN in your local editor
```

Never ask users to paste token values into chat.

## Required User-Facing Warnings

1. Missing `asset_id` warning:
`Field mapping is inferred because asset_id is missing; providing asset_id will improve accuracy and smoother development.`
2. Missing token warning:
`Real data sampling is unavailable because CORVA_BEARER_TOKEN is not set in .env.local.`
3. No-data warning:
`No data was found for this collection and asset in the selected environment.`

## Transition Back to Real Sampling

When token and `asset_id` become available:

1. Run real sampling immediately.
2. Re-run field summary from sample data.
3. Replace inferred-only assumptions with sampled mappings.
4. Call out any schema differences discovered after sampling.

## Optional Detailed Sampling Path

If you need lower-level sampling manually:

```bash
set -a
source <app-root>/.env.local
set +a

CORVA_DATA_API_BASE_URL="https://data-api.qa.cloud.corva.ai" \
CORVA_PROVIDER="corva" \
CORVA_COLLECTION="wits.summary-6h" \
CORVA_ASSET_ID="12345" \
<skill-root>/scripts/fetch_samples_with_env_token.sh > /tmp/corva_samples.json

node <skill-root>/scripts/infer_field_presence.js /tmp/corva_samples.json
```
