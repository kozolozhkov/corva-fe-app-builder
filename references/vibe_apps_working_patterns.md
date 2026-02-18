# Vibe Apps Working Patterns

## Source Files
- `<repo-root>/demos/vibe_coded_sample_app/src/App.tsx`
- `<repo-root>/demos/vibe_coded_sample_app/src/effects/useWitsData.ts`
- `<repo-root>/demos/vibe_coded_demo_app/src/App.tsx`
- `<repo-root>/demos/vibe_coded_demo_app/src/effects/useRopData.ts`

## Shared Flow

1. Resolve active well list with `useMemo`.
2. Extract `assetId` from selected well (`wellsList[0]?.asset_id`).
3. Call custom hook with `{ assetId, limit }`.
4. Render state branches:
- loading
- error
- no asset selected
- chart/content

## Data Fetch Pattern

Both hooks use:
- `corvaDataAPI.get('/api/v1/data/{provider}/{dataset}/', params)`
- params include `limit`, `skip`, `sort`, `query`

Sample app:
- dataset: `wits.summary-6h`
- provider: `corva`
- query: `{"asset_id": assetId}`

Demo app additionally uses:
- `fields: 'timestamp,data.rop,data.state'`

## Realtime Pattern

Both hooks subscribe via:
`socketClient.subscribe({ provider, dataset, assetId }, { onDataReceive })`

Implementation notes:
- Store `unsubscribe` callback in effect scope.
- Cleanup by calling `unsubscribe?.()`.
- Append incoming points and trim/deduplicate in hook state.

## Data Hygiene Pattern

From `useRopData.ts`:
- ignore invalid sentinel values (`-999.25`)
- normalize record to chart point shape
- deduplicate by timestamp
- sort ascending by timestamp for rendering

## AppSettings Pattern

Both demos use identical settings contract:
- `settings` from props
- merge with defaults
- call `onSettingChange` on control updates

Use this as a stable baseline for new Corva FE app scaffolds.
