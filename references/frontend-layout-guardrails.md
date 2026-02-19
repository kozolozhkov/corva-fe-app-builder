# Frontend Layout Guardrails

Use these rules for every app UI implementation to prevent clipped content and non-scrollable views.

## Core Rule: Scroll Owner

The default scroll owner must be `AppContainer` content, not an inner page wrapper.

Implementation pattern:
1. In app root:
- set `elementsClassNames={{ content: styles.appContent }}` on `AppContainer`
2. In CSS for `appContent`:
- `min-height: 0;`
- `overflow-y: auto;`
- `overflow-x: hidden;`

If bottom content is clipped, fix scroll ownership first before adjusting other layout rules.

## Root Layout Rules

1. Do not rely on `min-height: 100%` alone to create scroll behavior.
2. Ensure the active scroll container can shrink (`min-height: 0`) and owns overflow.
3. Keep page wrappers inside scroll container simple:
- use `display: flex; flex-direction: column;`
- add bottom padding so legends/toolbars are not cut off

## Adaptive Sizing Rules

For large blocks (charts, large tables, logs):
1. size from `coordinates.pixelHeight` (or `useAppSize`)
2. clamp with min/max bounds (example: chart `240..420`)
3. reserve bottom chart spacing when legends are visible

Recommended chart options baseline:
- explicit `chart.height`
- extra bottom spacing (`chart.spacing` bottom value > top value when legend is shown)
- bottom legend alignment for predictable clipping behavior

## Verification Checklist (required after UI edits)

1. In widget mode (not maximized), last content row is reachable.
2. In maximized mode, layout remains usable and not over-compressed.
3. If content exceeds viewport, internal app scroll is available.
4. No hidden bottom legend/toolbar content.
5. Record `layout=pass|fail` in iteration status.
6. Run `<skill-root>/scripts/layout_guardrail_check.sh --app-root <app-root>` and require `RESULT=pass`.

## Hard Gate Policy

1. If the layout guardrail check fails, do not continue feature work.
2. Patch scroll ownership first (`AppContainer` content + CSS overflow/min-height).
3. Re-run the guardrail script and proceed only after pass.

## Troubleshooting Order

Use this order to avoid random CSS trial-and-error:
1. Move overflow ownership to `AppContainer` content via `elementsClassNames.content`
2. Add/confirm `min-height: 0` on the active scroll container
3. Add bottom padding and chart bottom spacing
4. Reduce or clamp large block heights
5. Re-check both widget and maximized modes
