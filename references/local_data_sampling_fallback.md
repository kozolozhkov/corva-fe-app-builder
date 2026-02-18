# Local Data Sampling Fallback

Use this only when repo docs and codex-optimized metadata are insufficient for field-level confidence.

## Source Files
- `docs/codex-optimized/README.md` (repo root)
- `docs/codex-optimized/datasets.json` (repo root)
- `<skill-root>/scripts/fetch_samples_with_env_token.sh`
- `<skill-root>/scripts/infer_field_presence.js`

## Step 1: Prefer codex-optimized first

Check `docs/codex-optimized/datasets.json` (repo root) for:
- group (`drilling` / `completions`)
- keys
- known fields and types

If query shape or required chart fields are still unclear, continue to sampling.

## Step 2: Load local env values

Put credentials in:
`<app-root>/.env.local`

If the file is missing, ask the user to add it first and include at least:
- `CORVA_BEARER_TOKEN=<token>`

Copy/paste starter template for users:

```bash
CORVA_BEARER_TOKEN=eyJhbGciOi...your_token_here...
```

Keep `.env.local` simple:
- only store `CORVA_BEARER_TOKEN`
- do not require users to persist provider/collection/base URL/asset vars in that file

Provider note:
- For Corva-managed datasets, use `provider=corva`.
- If unsure, ask user for expected source/company (for example halliburton, slb, liberty).

If token is missing, explicitly state:
`No bearer token is set yet. We can continue planning, but real data sampling is unavailable and field mapping will be inferred until a token is added.`

Required runtime env vars for the fetch script:
- `CORVA_BEARER_TOKEN`
- `CORVA_DATA_API_BASE_URL`
- `CORVA_PROVIDER`
- `CORVA_COLLECTION`
- `CORVA_ASSET_ID`

Recommendation:
- source token from `.env.local`
- pass the non-secret runtime vars inline in the command

If `CORVA_ASSET_ID` is missing, explicitly state:
`No asset_id is available, so real data samples cannot be fetched.`

Optional:
- `CORVA_LIMIT` (default `10`, must be `5..20`)
- `CORVA_FIELDS`
- `CORVA_SORT`
- `CORVA_QUERY` (optional override for nested keys such as `metadata.asset_id`)

## Step 3: Fetch sample rows

```bash
set -a
source <app-root>/.env.local
set +a

CORVA_DATA_API_BASE_URL="https://data-api.qa.cloud.corva.ai" \
CORVA_PROVIDER="corva" \
CORVA_COLLECTION="wits.summary-6h" \
CORVA_ASSET_ID="12345" \
<skill-root>/scripts/fetch_samples_with_env_token.sh > /tmp/corva_samples.json
```

If `/tmp/corva_samples.json` contains zero records (for example `[]` or `{ "data": [] }`), stop sampling flow and explicitly tell the user:
`No data was found for this collection and asset in the selected environment.`

Then suggest the next minimal step (one at a time), for example:
1. confirm `asset_id`
2. try another collection
3. try another environment

## Step 4: Infer field presence

```bash
node <skill-root>/scripts/infer_field_presence.js /tmp/corva_samples.json
```

Output columns:
- flattened field path
- presence ratio
- present records / total records
- inferred type union
- nullability hint

Then enrich the output with field meaning notes:
- For each field path, add a short plain-language description of what it represents.
- Mark meaning confidence as `documented` (from metadata/docs) or `inferred` (from name + sample values).

## Step 5: Mandatory User-Facing Field Summary

After Step 4, always show the user a field/data availability summary.

Minimum required content:
1. Total sampled records count.
2. Top-level fields present.
3. Flattened field list with presence ratio, inferred types, and nullability.
4. Field-by-field meaning/explanation in plain language with confidence label (`documented` or `inferred`).
5. Explicit callouts for fields required by planned UI that are missing or sparse.

Do not continue as if schema is certain without presenting this summary.

## Weak-Coverage Warning Rules (must report)

Raise explicit warnings in planning output when any condition is true:
1. Sample size `< 5` records.
2. Required UI field has presence ratio `< 0.8`.
3. Required UI field type union is ambiguous (for example `number|string`).
4. Asset key mismatch risk:
- top-level `asset_id` sparse/missing
- nested `metadata.asset_id` present

If warnings exist, say query shape is provisional and request either:
- larger sample window, or
- explicit dataset contract confirmation.
