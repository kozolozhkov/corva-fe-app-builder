# Data API GET Catalog

## Source Files
- `<repo-root>/data-api/app/api/v1/router.py`
- `<repo-root>/data-api/app/api/v1/data.py`
- `<repo-root>/data-api/app/api/v1/dataset.py`
- `<repo-root>/corva-ui/src/clients/jsonApi/index.js`
- `<repo-root>/docs/codex-optimized/README.md`
- `<repo-root>/docs/codex-optimized/datasets.json`

## Regenerate Catalog

Run:
`CORVA_REPO_ROOT=<repo-root> <skill-root>/scripts/list_data_api_get_endpoints.sh`

## Route Truth (GET)

- `GET /api/v1/data/{provider}/{dataset}/`
- `GET /api/v1/data/{provider}/{dataset}/aggregate/`
- `GET /api/v1/data/{provider}/{dataset}/aggregate/pipeline/`
- `GET /api/v1/data/{provider}/{dataset}/{id}/`
- `GET /api/v1/dataset/`
- `GET /api/v1/dataset/company/`
- `GET /api/v1/dataset/{provider}/{name}/`
- `GET /api/v1/dataset/{provider}/{dataset}/index/{index}/`

## Query Semantics (from `data.py`)

For `GET /api/v1/data/{provider}/{dataset}/`:
- `limit` is required and constrained (`1..10000`)
- `skip` default `0`
- `fields` supports comma-separated projection
- `sort` comes from shared sorting dependency
- `query` comes from search query dependency

For `GET /api/v1/data/{provider}/{dataset}/aggregate/`:
- required `match`
- optional `group`, `project`, `sort`, `skip`, `limit`

For `GET /api/v1/data/{provider}/{dataset}/aggregate/pipeline/`:
- required `stages` JSON query arg

## Asset-First Query Rule

Default read shape for indexed time/depth collections:
- `query={"asset_id": <asset_id>}`
- explicit `sort` and bounded `limit`

Use codex-optimized metadata first:
- dataset group, keys, and field abbreviations live in `<repo-root>/docs/codex-optimized/datasets.json`
- this file contains 87 datasets (`drilling` + `completions`)

## Timeseries Key Caveat

Even when codex metadata emphasizes `asset_id`, confirm live samples before final query finalization.
Some datasets may key by nested metadata (for example `metadata.asset_id`) depending on provider pipeline/version.

Use fallback sampling workflow:
- `<skill-root>/references/local_data_sampling_fallback.md`
