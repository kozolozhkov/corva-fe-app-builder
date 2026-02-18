# Strict Preflight

Use this reference when the run must meet strict reliability checks before codegen or final handoff.

## Before Build Checklist

1. Confirm Corva UI MCP diagnostics pass (`mcp__corva_ui__get_diagnostics`).
2. Confirm `<app-root>/.env.local` exists.
3. Confirm `CORVA_BEARER_TOKEN` is set if real data sampling is required.
4. Confirm `provider`, `environment`, `asset_id`, and `goal_intent`.
5. Resolve `collection` from user input or intent mapping.
6. Confirm `<app-root>` contains `package.json` and a `start` script.

If token is missing, tell the user:

`No bearer token is set yet. We can continue planning, but real data sampling is unavailable and field mapping will be inferred until a token is added.`

If `asset_id` is missing, tell the user:

`No asset_id is available yet, so real data samples cannot be fetched for the target asset.`

## Mandatory Setup Question Flow

Use this exact one-question-at-a-time order when strict setup is required:

1. `Step 1/5: What is the asset_id for the target well/asset?`
2. `Step 2/5: Please confirm .env.local exists in the app root and includes CORVA_BEARER_TOKEN (yes/no).`
3. `Step 3/5: Which provider should we use? If this is a Corva dataset, reply corva.`
4. `Step 4/5: Which environment should we use (qa or prod)?`
5. `Step 5/5: In plain language, what should this app show (for example frac stages, pump rate trend, or pressure vs time)?`

If step 2 is `no` or `unsure`, show:

```bash
CORVA_BEARER_TOKEN=eyJhbGciOi...your_token_here...
```

Then ask: `Please reply "ready" after this is set.`

## Required Context Gate

Collect and confirm all fields before strict codegen:

1. `environment`
2. `provider`
3. `asset_id`
4. `goal_intent`
5. `collection` (provided or inferred)

If any field is missing, ask one question for the highest-priority missing item in this order:

1. `asset_id`
2. token presence in `.env.local`
3. `provider`
4. `environment`
5. `goal_intent`

## Strict Preflight Sequence

Run before planning/code and after every iteration:

1. MCP health (`mcp__corva_ui__get_diagnostics`).
2. Token check (`.env.local` + `CORVA_BEARER_TOKEN`).
3. Context gate check (`environment`, `provider`, `asset_id`, `goal_intent`, `collection`).
4. Sampling check: if samples were fetched, verify field summary was presented and no-data state was explicit when applicable.
5. Runtime check: FE server responds; restart if needed.
6. Layout fit check after UI changes.
7. Styling compliance check after UI/styling changes.

If any strict preflight check fails, stop codegen and ask one short unblock question.

## Runtime Server Rule (strict)

1. Start FE server from app root with `yarn start` (or `scripts/start_or_restart_dev.sh`).
2. Record local URL from logs (fallback `http://localhost:3000`).
3. On first local run, remind login: `https://app.local.corva.ai`.
4. Tell user to open the URL and keep terminal running for live reload.
5. Re-check URL every iteration; if down, restart and report restart status.

## Guided Setup Message Format

When strict setup context is incomplete, each response must contain:

1. One short step line.
2. Exactly one question.
3. Optional helper note only when needed.

Do not include status blocks, endpoint plans, or runtime URLs while strict setup is incomplete.

## Iteration Status Contract

When context is complete and strict mode is active, include one compact status line:

`MCP=<pass/fail> | Token=<present/missing> | asset_id=<known/missing> | sample=<not-run/has-data/no-data> | server=<running/restarted/not-running> | layout=<pass/fail>`
