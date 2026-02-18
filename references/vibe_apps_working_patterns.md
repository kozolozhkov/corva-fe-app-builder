# Working FE Data Patterns

Use these patterns as the default implementation baseline for Corva FE apps.
No local demo app files are required.

## Shared Flow

1. Resolve `assetId` from current app context.
2. Call one data hook with explicit inputs (`assetId`, `provider`, `collection`, `limit`).
3. Render state branches in this order:
- loading
- error
- missing asset
- no data
- chart/content

## Initial Fetch Pattern

Use `corvaDataAPI` with explicit query params.

```ts
const params = {
  query: JSON.stringify({ asset_id: assetId }),
  sort: JSON.stringify({ timestamp: 1 }),
  limit,
  skip: 0,
};

const { data } = await corvaDataAPI.get(
  `/api/v1/data/${provider}/${collection}/`,
  params
);
```

Notes:
- Keep query explicit and deterministic.
- Validate `asset_id` vs `metadata.asset_id` from samples before finalizing.

## Realtime Pattern

```ts
const unsubscribe = socketClient.subscribe(
  { provider, dataset: collection, assetId },
  {
    onDataReceive: (point) => {
      // normalize, append, deduplicate, trim
    },
  }
);

return () => unsubscribe?.();
```

Notes:
- Keep subscribe/unsubscribe inside one effect scope.
- Normalize incoming records before merging into state.

## Hook Contract Pattern

Return a stable shape:

- `data`
- `loading`
- `error`
- `lastUpdated` (optional)

This keeps UI components simple and predictable.

## Data Quality Pattern

Apply these transforms before render:

1. drop invalid or sentinel values when applicable
2. normalize records into chart-ready shape
3. deduplicate on x-axis key
4. sort ascending for chart rendering

## UI Pattern

Keep UI components presentational:

- no API calls inside chart components
- no socket logic inside chart components
- all fetch/realtime logic in hooks

## Settings Pattern

Maintain one settings contract:

- merge `DEFAULT_SETTINGS` with incoming settings
- update values only through `onSettingChange`
- keep settings values serializable and minimal
