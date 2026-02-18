# Styling Compliance

Use this reference whenever UI or styling changes are part of the iteration.

## Theme-First Rule

1. Call Corva UI MCP docs before styling decisions:
- `list_corva_ui`
- `search_corva_ui`
- `get_component_docs`
- `get_theme_docs` (mandatory)
2. Build a style token plan (palette, typography, spacing) from theme docs before custom CSS.

## Component and Token Rules

1. Prefer `@corva/ui` components over custom implementations where equivalents exist.
2. Use Corva theme tokens for colors, typography, spacing, and borders.
3. Avoid custom hex/rgb/hsl values when an equivalent theme token exists.
4. Avoid hardcoded brand palettes unless the user explicitly requests them.

## Layout Fit Rules

When UI layout changes, apply `references/frontend-layout-guardrails.md`:

1. Ensure bottom content is reachable in widget mode.
2. Ensure scroll ownership is clear (app content handles scrolling when needed).
3. Ensure chart/table containers fit the widget without clipping.

## Compliance Pass Checklist

Run this pass before finalizing a UI iteration:

1. Theme token usage verified.
2. `@corva/ui` components used where applicable.
3. Custom overrides justified and minimal.
4. Widget fit/scroll behavior verified.

## Required Note in Iteration Output

When UI/styling changes are included, add a short note that states:

1. Which Corva tokens/components were used.
2. Which overrides were kept and why they were needed.

## Mismatch Response

If user reports styling mismatch:

1. Pause new feature work.
2. Re-run Corva UI MCP theme/component checks.
3. Patch styling compliance first.
4. Resume feature work only after compliance is restored.
