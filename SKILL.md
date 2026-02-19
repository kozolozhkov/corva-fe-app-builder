---
name: corva-fe-app-builder
description: "Build and iterate Corva FE apps with @corva/ui defaults, real-data-first sampling, and safe inferred fallbacks when required context is missing. Use when users ask to scaffold or upgrade Corva widgets/apps for drilling or completions." 
metadata:
  standard: agentskills-v1
  compatibility: codex,claude-code,cursor,agentskills-hosts
  primary-interface: SKILL.md
---

# Corva FE App Builder

Use this skill to move from app intent to a running Corva FE app with real-data-first behavior and explicit confidence reporting.

## Path Placeholders

- `<app-root>`: target FE app folder (contains `package.json` and usually `.env.local`).
- `<skill-root>`: installed `corva-fe-app-builder` skill folder (contains `SKILL.md`, `references/`, and `scripts/`).

## Open Standard Compatibility

This skill follows the open Agent Skills format commonly used by [skills.sh](https://skills.sh).

1. Keep core workflow in `SKILL.md`, and deeper detail in `references/`.
2. Prefer capability names over host-specific tool aliases.
3. Use `scripts/` as deterministic fallbacks when MCP aliases differ across hosts.
4. Treat `agents/openai.yaml` as optional host metadata; it is not required by non-OpenAI hosts.

## Defaults

- `provider=corva` unless the user explicitly requests another provider.
- `environment=prod` unless the user explicitly requests another environment.
- `data_api_base_url=https://data.corva.ai` unless `--base-url` or `CORVA_DATA_API_BASE_URL` overrides it.
- infer `collection` from first prompt intent; ask one options question only when confidence is low.

## Token Security (mandatory)

1. Never ask users to paste or send bearer tokens in chat.
2. Require users to create/update `<app-root>/.env.local` locally and reply `ready`.
3. Verify token presence only via local file checks (`.env.local` + `CORVA_BEARER_TOKEN`).
4. Never echo token values in logs, snippets, or assistant responses.

## Communication Style

1. Use plain language and short sequential steps.
2. Ask one question at a time while setup is incomplete.
3. Keep setup messages compact: one step line, one question, optional helper line.

## MCP Bootstrap Gate (run first)

1. Run Corva UI diagnostics (`get_diagnostics` capability).
- Codex alias: `mcp__corva_ui__get_diagnostics`
- Other hosts (including Claude Code): use the alias exposed for `corva_ui.get_diagnostics`.
2. If diagnostics fail, run `npx -p @corva/ui corva-ui-mcp-setup`.
3. If MCP config changed, require host restart, then run diagnostics again.
4. Use Corva UI MCP tools directly through host aliases (`list_corva_ui`, `search_corva_ui`, `get_component_docs`, `get_theme_docs`, etc.).

## Unified Workflow

1. Confirm `<app-root>`.
2. Capture `goal_intent` from the first user prompt.
3. Ask/confirm `asset_id` early.
4. Verify local token presence in `<app-root>/.env.local`.
5. Resolve `collection` from dataset metadata and intent.
6. Attempt real sampling immediately when both token and `asset_id` are available.
7. Scaffold/build the app with confidence labels:
- `sampled` when schema comes from real data sample.
- `inferred` when schema comes from dataset definitions or heuristics.
8. Start or recover runtime via `scripts/start_or_restart_dev.sh` and provide local URL instructions.

## Required Setup Sequence

Ask one question at a time in this order:

1. `Step 1/2: What is the asset_id for the target well/asset?`
2. `Step 2/2: Please create or update .env.local locally so it contains CORVA_BEARER_TOKEN, then reply "ready" (do not paste the token in chat).`

If the user is blocked on step 2, show:

```bash
touch <app-root>/.env.local
chmod 600 <app-root>/.env.local
# Add CORVA_BEARER_TOKEN in your local editor (do not paste it in chat)
```

Then ask: `Please reply "ready" after this is set locally.`

## Sampling and Fallback Rules

Real-data-first trigger:

- If `asset_id` and token are both available, sampling is required before final field mapping.

Fallback contract:

1. Missing `asset_id`:
- continue with inferred collection/field mapping from dataset definitions.
- explicitly warn: `Field mapping is inferred because asset_id is missing; providing asset_id will improve accuracy and smoother development.`
- ask one next question for `asset_id`.
2. Missing token:
- continue with inferred mapping/scaffold.
- explicitly warn: `Real data sampling is unavailable because CORVA_BEARER_TOKEN is not set in .env.local.`
- ask user to set local `.env.local` and reply `ready`.
3. Sampling returns no data:
- explicitly state: `No data was found for this collection and asset in the selected environment.`
- continue with inferred mapping and mark schema confidence as provisional.

## Reliability and Quality Checks

Run before planning/code and after each iteration:

1. MCP diagnostics pass.
2. Context check (`provider`, `environment`, `goal_intent`, `collection`) with defaults applied.
3. Token file check (`.env.local`, token presence, permissions).
4. Sampling status check (sampled or inferred fallback explicitly reported).
5. Runtime check (local app URL responds; restart if needed).
6. Layout fit hard gate after UI changes (`scripts/layout_guardrail_check.sh` must pass).
7. Corva styling compliance check after UI/styling changes.

If check 6 fails, pause feature work and patch layout scroll ownership before continuing.

## Runtime Server Rule

1. Start FE server from app root with `yarn start` (or `scripts/start_or_restart_dev.sh`).
2. Record local URL from logs (fallback `http://localhost:3000`).
3. On first local run, remind login: `https://app.local.corva.ai`.
4. Tell user to open URL and keep terminal running for live reload.
5. Re-check URL every iteration; restart and report if unavailable.

## Script Quickstart

- Preflight check:

```bash
<skill-root>/scripts/preflight.sh --app-root <app-root>
```

- Compatibility strict preflight (`--strict` preserved):

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
  --collection <collection> \
  --asset-id <asset_id>
```

- Layout guardrail hard check (required after UI edits):

```bash
<skill-root>/scripts/layout_guardrail_check.sh --app-root <app-root>
```

## Strict References

- `references/preflight-strict.md`: required checks and setup gating.
- `references/data-sampling.md`: sampling trigger, reporting, and fallback handling.
- `references/styling-compliance.md`: Corva theme/component compliance.

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
