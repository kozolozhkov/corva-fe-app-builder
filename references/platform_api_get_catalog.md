# Platform API GET Catalog

## Source File
- `/Users/kzolozhkov/corva/core/corva-api/config/routes.rb`

## Regenerate Catalog

Run:
`/Users/kzolozhkov/.codex/skills/corva-fe-app-builder/scripts/list_platform_get_endpoints.sh`

## v1 Metadata Endpoints (derived from routes)

- `GET /v1/assets`
- `GET /v1/assets/:id`
- `GET /v1/assets/ids`
- `GET /v1/assets/:id/active_child`
- `GET /v1/assets/:id/app_stream`
- `GET /v1/assets/:id/settings`
- `GET /v1/wells`
- `GET /v1/wells/:id`
- `GET /v1/programs`
- `GET /v1/programs/:id`
- `GET /v1/rigs`
- `GET /v1/rigs/:id`
- `GET /v1/users`
- `GET /v1/users/:id`
- `GET /v1/users/autocomplete`
- `GET /v1/users/current`
- `GET /v1/users/current/recent_assets`
- `GET /v1/companies`
- `GET /v1/companies/:id/corva_apps_installed`

## v2 Metadata Endpoints (derived from routes)

- `GET /v2/assets`
- `GET /v2/assets/:id`
- `GET /v2/assets/autocomplete`
- `GET /v2/assets/:id/settings`
- `GET /v2/assets/:id/reruns`
- `GET /v2/assets/:id/ancestor_ids`
- `GET /v2/wells`
- `GET /v2/wells/:id`
- `GET /v2/wells/clusters`
- `GET /v2/rigs`
- `GET /v2/rigs/:id`
- `GET /v2/rigs/clusters`
- `GET /v2/programs`
- `GET /v2/programs/:id`
- `GET /v2/programs/clusters`
- `GET /v2/pads`
- `GET /v2/pads/:id`
- `GET /v2/pads/clusters`
- `GET /v2/frac_fleets`
- `GET /v2/frac_fleets/:id`
- `GET /v2/frac_fleets/wells`
- `GET /v2/frac_fleets/clusters`
- `GET /v2/drillout_units`
- `GET /v2/drillout_units/:id`
- `GET /v2/drillout_units/clusters`
- `GET /v2/intervention_units`
- `GET /v2/intervention_units/:id`
- `GET /v2/users`
- `GET /v2/users/:id`
- `GET /v2/users/autocomplete`
- `GET /v2/users/current`
- `GET /v2/users/export`
- `GET /v2/users/streaks`
- `GET /v2/companies`
- `GET /v2/companies/:id`
- `GET /v2/picklists`
- `GET /v2/picklists/:name`

## Usage Guidance For FE App Builder

1. Use these endpoints for platform metadata resolution (asset/well/rig/user context) before data collection reads.
2. Keep data reads on Data API (`/api/v1/data/...`), not on platform `v1 data` legacy paths.
3. Prefer resource-specific methods from `/Users/kzolozhkov/corva/core/corva-ui/src/clients/jsonApi/index.js` where available.
