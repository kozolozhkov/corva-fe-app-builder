# App Patterns From Repo

## Source Files
- `<repo-root>/demos/vibe_coded_sample_app/src/index.js`
- `<repo-root>/demos/vibe_coded_sample_app/src/App.tsx`
- `<repo-root>/demos/vibe_coded_sample_app/src/AppSettings.tsx`
- `<repo-root>/demos/vibe_coded_sample_app/src/effects/useWitsData.ts`
- `<repo-root>/demos/vibe_coded_demo_app/src/index.js`
- `<repo-root>/demos/vibe_coded_demo_app/src/App.tsx`
- `<repo-root>/demos/vibe_coded_demo_app/src/AppSettings.tsx`
- `<repo-root>/demos/vibe_coded_demo_app/src/effects/useRopData.ts`

## Proven Scaffold Shape

1. Export app entry as default object with `component` + `settings`.
`<repo-root>/demos/vibe_coded_sample_app/src/index.js`
`<repo-root>/demos/vibe_coded_demo_app/src/index.js`

2. Keep root default exports `App` and `AppSettings` unchanged (explicit warning comments in both apps).

3. Wrap UI with:
- `AppContainer`
- `AppHeader`
- `useAppCommons` for `appKey`
From:
`<repo-root>/demos/vibe_coded_sample_app/src/App.tsx`
`<repo-root>/demos/vibe_coded_demo_app/src/App.tsx`

4. Resolve asset from selected well list:
- Build `wellsList` with `useMemo`
- Use `wellsList[0]?.asset_id`

5. Separate data logic into `effects/use*.ts` hook.
The app component handles rendering states; the hook handles API and subscriptions.

## AppSettings Pattern

- Use `DEFAULT_SETTINGS` merge pattern:
`const settings = { ...DEFAULT_SETTINGS, ...apiSettings };`
- Update values via `onSettingChange(key, value)`.
From:
`<repo-root>/demos/vibe_coded_sample_app/src/AppSettings.tsx`
`<repo-root>/demos/vibe_coded_demo_app/src/AppSettings.tsx`

## Data Hook Pattern

From:
- `<repo-root>/demos/vibe_coded_sample_app/src/effects/useWitsData.ts`
- `<repo-root>/demos/vibe_coded_demo_app/src/effects/useRopData.ts`

Common flow:
1. Exit early when `assetId` is missing.
2. Fetch initial window via `corvaDataAPI.get('/api/v1/data/...')`.
3. Subscribe realtime via `socketClient.subscribe({ provider, dataset, assetId }, { onDataReceive })`.
4. Return cleanup that calls `unsubscribe?.()`.
5. Keep hook state: `data`, `loading`, `error` (+ optional `lastUpdated`).

## Best Practices Derived From Working Implementations

- Keep data query explicit: `limit`, `skip`, `sort`, `query`, optional `fields`.
- Prefer ascending `timestamp` for chart rendering paths.
- Filter invalid sentinel values in the hook (`-999.25` in demo ROP hook).
- Deduplicate realtime points by timestamp before chart render.
- Maintain clear rendering states: loading, error, no asset, content.
