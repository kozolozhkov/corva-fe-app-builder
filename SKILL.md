---
name: corva-fe-app-builder
description: "Scaffold and iterate Corva FE apps quickly with @corva/ui defaults, optional real-data wiring, and optional hardening checks. Use for new apps, widget screens, and mock-to-production upgrades."
---

# Corva FE App Builder

Use this skill to get from app idea to running Corva FE app quickly, then harden only when needed.

## Path Placeholders

- `<app-root>`: target FE app folder (contains `package.json` and usually `.env.local`).
- `<skill-root>`: installed `corva-fe-app-builder` skill folder (contains `SKILL.md`, `references/`, and `scripts/`).

## Operating Modes

1. `fast-start` (default): scaffold UI, use mock data if needed, run app locally.
2. `real-data`: wire provider/collection/asset and validate with sample fetches.
3. `hardening`: run strict preflight and compliance checks before final delivery.

Default to `fast-start` unless the user asks for stricter reliability gates.

Default assumptions during setup:

- `provider=corva` unless user instructs otherwise.
- `environment=prod` unless user instructs otherwise.
- infer `collection` from the first prompt; only ask a single options question when confidence is low.

## Communication Style

Assume mixed experience levels; keep language plain and ask one question at a time.

1. Keep responses short and sequential.
2. Avoid jargon; explain required technical terms in one sentence.
3. Ask only one setup question per turn while context is incomplete.
4. Keep setup messages compact: one short step line and one question.

## MCP Bootstrap Gate (run first)

1. Run `mcp__corva_ui__get_diagnostics`.
2. If diagnostics fail, run `npx -p @corva/ui corva-ui-mcp-setup`.
3. If MCP config changed, ask for a full Codex restart, then run diagnostics again.
4. Use Corva UI MCP tools directly (`list_corva_ui`, `search_corva_ui`, `get_component_docs`, `get_theme_docs`, etc.).

## Fast-Start Workflow (default)

1. Confirm `<app-root>` (fallback to current working directory if clear).
2. Ask for the user goal in plain language.
3. Build scaffold from:
- `references/app_scaffold_patterns.md`
- `references/data_hook_patterns.md`
4. Plan UI with Corva UI MCP (`get_theme_docs` is required before choosing colors).
5. Start or recover local runtime with `scripts/start_or_restart_dev.sh`.
6. Share local URL and remind user to keep terminal running.
7. If first run is unauthenticated, remind login: `https://app.local.corva.ai`.

## Real-Data Workflow (when requested)

1. Collect and confirm: `asset_id`, `goal_intent`, and `collection`; apply defaults `provider=corva` and `environment=prod` unless user overrides.
2. Build endpoint plan using:
- `references/client_method_to_endpoint_map.md`
- `references/data_api_get_catalog.md`
- `references/platform_api_get_catalog.md`
3. Run `scripts/sample_data.js` for real sample fetch + field summary.
4. Follow reporting contract in `references/data-sampling.md`.

## Hardening Workflow (when requested or before sign-off)

1. Run `scripts/preflight.sh --strict` with required context arguments.
2. Apply strict flow in `references/preflight-strict.md`.
3. Apply layout fit rules from `references/frontend-layout-guardrails.md`.
4. Apply styling checks from `references/styling-compliance.md`.

## Script Quickstart

- Preflight checks:

```bash
<skill-root>/scripts/preflight.sh --app-root <app-root>
```

- Strict preflight checks:

```bash
<skill-root>/scripts/preflight.sh \
  --strict \
  --app-root <app-root> \
  --asset-id <asset_id> \
  --goal-intent "<goal>" \
  --collection <collection>
```

- Start or restart dev server:

```bash
<skill-root>/scripts/start_or_restart_dev.sh --app-root <app-root>
```

- Fetch sample data and summarize fields:

```bash
<skill-root>/scripts/sample_data.js \
  --app-root <app-root> \
  --base-url <data_api_base_url> \
  --collection <collection> \
  --asset-id <asset_id>
```

## Strict References (detailed rules moved out of SKILL.md)

- `references/preflight-strict.md`: strict setup flow, context gate, preflight sequence, runtime rule, and iteration contract.
- `references/data-sampling.md`: sample-fetch procedure, field-by-field reporting contract, and no-data handling.
- `references/styling-compliance.md`: Corva theme token checks, component usage rules, and override policy.

## References

- `references/app_scaffold_patterns.md`
- `references/mcp_usage.md`
- `references/data_api_get_catalog.md`
- `references/platform_api_get_catalog.md`
- `references/client_method_to_endpoint_map.md`
- `references/data_hook_patterns.md`
- `references/dataset_descriptions/README.md`
- `references/dataset_descriptions/datasets.json`
- `references/local_data_sampling_fallback.md`
- `references/security_local_token_rules.md`
- `references/frontend-layout-guardrails.md`
- `references/preflight-strict.md`
- `references/data-sampling.md`
- `references/styling-compliance.md`
