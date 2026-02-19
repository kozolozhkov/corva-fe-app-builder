# Required Preflight for Reliable Real-Data Wiring

Use this reference to enforce reliable setup, sampling, and reporting before final handoff.

## Required Checks Before Reliable Real-Data Wiring

1. Confirm Corva UI MCP diagnostics pass (`get_diagnostics` capability; Codex alias is `mcp__corva_ui__get_diagnostics`).
2. Confirm `<app-root>/.env.local` exists.
3. Confirm `CORVA_BEARER_TOKEN` is set when real sampling is attempted.
4. Apply defaults unless user overrides: `provider=corva`, `environment=prod`.
5. Confirm `asset_id` early.
6. Derive `goal_intent` from user prompt.
7. Resolve `collection` from intent mapping (ask options only when confidence is low).
8. Confirm `<app-root>` contains `package.json` and a `start` script.

If token is missing, tell the user:

`No bearer token is set yet. We can continue scaffolding with inferred mapping, but real data sampling is unavailable until CORVA_BEARER_TOKEN is set in .env.local.`

Then ask user to update `<app-root>/.env.local` locally and reply `ready`.

Never ask the user to paste token values into chat.

If `asset_id` is missing, tell the user:

`Field mapping is inferred because asset_id is missing; providing asset_id will improve accuracy and smoother development.`

## Required Setup Questions (one-at-a-time)

1. `Step 1/2: What is the asset_id for the target well/asset?`
2. `Step 2/2: Please create or update .env.local locally so it contains CORVA_BEARER_TOKEN, then reply "ready" (do not paste the token in chat).`

If the user needs help for step 2, show:

```bash
touch <app-root>/.env.local
chmod 600 <app-root>/.env.local
# Add CORVA_BEARER_TOKEN in your local editor (do not paste it in chat)
```

Then ask: `Please reply "ready" after this is set locally.`

## Context and Fallback Contract

Required context fields:

1. `environment` (default `prod`)
2. `provider` (default `corva`)
3. `asset_id` (preferred; fallback allowed)
4. `goal_intent`
5. `collection` (inferred or chosen)

Fallbacks that are explicitly allowed:

1. No `asset_id`:
- continue with inferred collection/fields from dataset metadata.
- mark confidence as `inferred`.
- ask one next unblock question for `asset_id`.
2. No token:
- continue with inferred scaffold.
- state that real sampling is unavailable until `.env.local` is set.
- ask one next unblock question for local token setup.
3. Sample no-data:
- state exact message: `No data was found for this collection and asset in the selected environment.`
- continue with inferred mapping and risk notes.

## Preflight Sequence (run each iteration)

1. MCP health (`get_diagnostics` capability via host alias).
2. Token file check (`.env.local` presence, restricted permissions, token presence).
3. Context check (`environment`, `provider`, `goal_intent`, `collection`) with defaults applied.
4. Sampling state check:
- if token + `asset_id` exist, sampling should be attempted.
- if sampling skipped, fallback reason must be explicit.
5. Runtime check: FE server responds; restart if needed.
6. Layout fit check after UI changes.
7. Styling compliance check after UI/styling changes.

If any required check fails, stop and ask one short unblock question.

## Runtime Server Rule

1. Start FE server from app root with `yarn start` (or `scripts/start_or_restart_dev.sh`).
2. Record local URL from logs (fallback `http://localhost:3000`).
3. On first local run, remind login: `https://app.local.corva.ai`.
4. Tell user to open URL and keep terminal running for live reload.
5. Re-check URL every iteration; restart and report if down.

## Guided Setup Message Format

When setup is incomplete, each response must contain:

1. One short step line.
2. Exactly one question.
3. Optional helper note only when needed.

Do not include status blocks, endpoint plans, or runtime URLs while setup is incomplete.

## Iteration Status Contract

When context is complete, include one compact status line:

`MCP=<pass/fail> | Token=<present/missing> | asset_id=<known/missing> | sample=<has-data/no-data/inferred> | server=<running/restarted/not-running> | layout=<pass/fail>`
