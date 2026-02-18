# Data API GET Catalog

This is a bundled route-truth reference for environments where only `<app-root>` and `<skill-root>` are available.

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

Use dataset metadata first:
- primary source: `<skill-root>/references/dataset_descriptions/datasets.json`
- use group, keys, and fields to rank candidate collections for the requested chart/widget intent

## Timeseries Key Caveat

Even when codex metadata emphasizes `asset_id`, confirm live samples before final query finalization.
Some datasets may key by nested metadata (for example `metadata.asset_id`) depending on provider pipeline/version.

Use fallback sampling workflow:
- `<skill-root>/references/local_data_sampling_fallback.md`
