# Client Method To Endpoint Map

This is a bundled client behavior reference for environments where only `<app-root>` and `<skill-root>` are available.

## Core HTTP Clients

1. `corvaAPI`
- wraps `get/post/put/patch/del` with `CORVA_API_URLS.API`

2. `corvaDataAPI`
- wraps `get/post/put/patch/del` with `CORVA_API_URLS.DATA_API`
- preferred for `/api/v1/data/...`

3. `socketClient`
- subscribe signature used in demos:
  `{ provider, dataset, assetId }`
- internally maps `dataset` to `collection`

## JSON API Method Mapping (app-building subset)

- `getWells(options)` -> `GET /v2/wells`
- `getWell(id, options)` -> `GET /v2/wells/{id}`
- `getRigs(options)` -> `GET /v2/rigs`
- `getRig(id, options)` -> `GET /v2/rigs/{id}`
- `getPrograms(options)` -> `GET /v2/programs`
- `getPads(options)` -> `GET /v2/pads`
- `getPad(id, options)` -> `GET /v2/pads/{id}`
- `getFracFleets(options)` -> `GET /v2/frac_fleets`
- `getFracFleet(id, options)` -> `GET /v2/frac_fleets/{id}`
- `getDrilloutUnits(options)` -> `GET /v2/drillout_units`
- `getDrilloutUnit(id, options)` -> `GET /v2/drillout_units/{id}`
- `getInterventionUnits(options)` -> `GET /v2/intervention_units`
- `getInterventionUnit(id, options)` -> `GET /v2/intervention_units/{id}`
- `getAssets(options)` -> `GET /v2/assets`
- `getAsset(id, options)` -> `GET /v2/assets/{id}`
- `getUsers(options)` -> `GET /v1/users`
- `getUsersWithHeaders(options)` -> `GET /v1/users` (returns data + headers)
- `getCurrentUser()` -> `GET /v1/users/current` (direct `fetch`, not wrapped `get`)

## Data API Mapping

- `getDataAppStorage(provider, collection, params)` -> `GET /api/v1/data/{provider}/{collection}/`
- `getDataAppStorageAggregate(provider, collection, params)` -> `GET /api/v1/data/{provider}/{collection}/aggregate/`
- `putDataAppStorage(provider, collection, id, item, queryParams)` -> `PUT /api/v1/data/{provider}/{collection}/{id}`
- `postDataAppStorage(provider, collection, item)` -> `POST /api/v1/data/{provider}/{collection}`

Common usage pattern: `corvaDataAPI.get('/api/v1/data/...', params)`.

## Header/Token Behavior

From the bundled client behavior model:

- Authorization header is attached from URL token or mobile session token (`getAuthorizationHeaders`).
- App key header `x-corva-app` is attached when discovered from xprops or stack trace.
- `fetch` credentials mode is `include`.

## Query Shape Rule

For data retrieval methods, pass explicit params:
- `query` JSON string
- `sort` JSON string
- `limit` and `skip`
- optional `fields`

Default app-builder rule:
- start with `query={"asset_id": <asset_id>}`
- validate against sample data if dataset appears to key by nested metadata fields.

## Deprecated Legacy Methods (Avoid For New App Scaffolds)

Marked deprecated in `jsonApi/index.js`:
- `getAppStorage`
- `putAppStorage`
- `postAppStorage`
- `deleteAppStorage`
- `deleteAppStorageRecords`

Prefer Data API methods above.
