# App Scaffold Patterns

Use this as the default scaffold blueprint when no local demo apps are available.

## Recommended File Layout

- `<app-root>/src/index.js`
- `<app-root>/src/App.tsx`
- `<app-root>/src/AppSettings.tsx`
- `<app-root>/src/effects/useData.ts`
- `<app-root>/src/components/*` (optional)

## Entry Contract

Expose app component + settings as the default export.

```js
import App from './App';
import AppSettings from './AppSettings';

export default {
  component: App,
  settings: AppSettings,
};
```

## App Shell Pattern

Use Corva shell primitives and keep app-level context in the top component.

- `AppContainer`
- `AppHeader`
- `useAppCommons` (for app key and common context)

## State Ownership Pattern

Keep responsibilities separate:

1. `App.tsx`: rendering states + layout + props wiring.
2. `effects/useData.ts`: initial fetch + realtime subscription + data normalization.
3. `AppSettings.tsx`: settings controls and defaults merge.

## Asset Resolution Pattern

Resolve the target asset early and short-circuit fetch until it is known.

- derive selected asset from context/selection
- pass `assetId` into data hook
- render explicit "no asset selected" state when missing

## Data Hook Baseline

Use one hook per dataset/visualization and keep it deterministic.

1. Return early when `assetId` is missing.
2. Fetch initial window with explicit params (`query`, `sort`, `limit`, `skip`, optional `fields`).
3. Subscribe realtime with `socketClient.subscribe({ provider, dataset, assetId }, ...)`.
4. Cleanup by calling `unsubscribe?.()`.
5. Return stable shape: `{ data, loading, error, lastUpdated }`.

## AppSettings Baseline

Keep settings contract predictable.

```ts
const settings = { ...DEFAULT_SETTINGS, ...apiSettings };
```

- read from incoming `settings`
- update through `onSettingChange(key, value)`
- keep defaults minimal and typed

## Rendering States Baseline

Always implement these branches:

- loading
- error
- no asset selected
- empty/no-data
- content

## Data Hygiene Baseline

- sort by time key before render
- deduplicate by primary x-axis key (usually timestamp)
- drop invalid/sentinel values when known
- keep transformation logic inside the hook, not UI components
