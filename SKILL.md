---
name: corva-fe-app-builder
description: "Plan and scaffold Corva FE apps with friendly MCP-first @corva/ui guidance, strict preflight and data reliability checks, asset-first query design, and clean one-question-at-a-time guidance."
---

# Corva FE App Builder

Use this skill to build Corva FE app plans and scaffolds with practical, proven implementation patterns.

## Path Placeholders

- `<repo-root>`: root of the Corva mono-repo/workspace that contains `corva-ui`, `docs`, `demos`, `data-api`, and `corva-api`.
- `<app-root>`: target FE app folder (contains `package.json` and `.env.local`).
- `<skill-root>`: installed `corva-fe-app-builder` skill folder (contains `SKILL.md`, `references/`, and `scripts/`).

## Communication Style (default)

Assume mixed experience levels; default to clear plain language unless the user asks for deeper technical detail.

1. Use plain language and a friendly tone.
2. Avoid jargon; if a technical term is required, explain it in one short sentence.
3. Keep steps short and sequential.
4. Ask one question at a time (never ask a block of questions).
5. During setup, keep each message minimal: one short step label, one question, and only required helper text.

## Friendly Coach Voice (mandatory)

Use a calm, encouraging tone without becoming verbose.

1. Sound warm and clear, not robotic or urgent.
2. Acknowledge the user answer briefly before the next question (for example: `Perfect, thanks.`).
3. Frame blockers as the next small step, not as failures.
4. Keep warning language gentle and practical; avoid fear-based wording.
5. Never stack multiple warnings in one message.

## Smoother Development Improvements (enabled)

1. Preflight checks are mandatory before planning/code and re-checked after each iteration.
2. Intent-to-collection guidance is required (suggest 1-3 best candidates from codex-optimized).
3. Golden app scaffold patterns from working vibe apps are the required baseline.
4. One-question-at-a-time interaction is enforced.
5. Real sample fetch must always be followed by an explicit field/data availability summary.
6. Empty sample fetch must be called out explicitly as no data.
7. Quality gate blocks codegen until required context + reliability checks pass.
8. Iteration output contract is required so users always see status, next step, and risks.
9. Setup flow must be calm and linear: one question per turn, no dense status blocks before context is complete.
10. Friendly coach voice is required during setup and discovery turns.

## Before Build Checklist (mandatory)

1. For components, styling, design system usage, and color schemes, always refer to Corva UI MCP tools first (`list_corva_ui`, `search_corva_ui`, `get_component_docs`, `get_theme_docs`).
2. Build a style-token plan (palette, typography, spacing) from Corva theme docs before writing custom styles.
3. Ensure Corva UI MCP is running and available (bootstrap gate below).
4. Ensure `<app-root>/.env.local` exists and `CORVA_BEARER_TOKEN` is present.
If token is missing, explicitly tell the user:
`No bearer token is set yet. We can continue planning, but real data sampling is unavailable and field mapping will be inferred until a token is added.`
5. Ask for `asset_id` before sampling. If no `asset_id`, explicitly tell the user:
`No asset_id is available yet, so real data samples cannot be fetched for the target asset.`
6. Confirm provider explicitly. If unsure, ask for expected data source/company (for example halliburton, slb, liberty). For Corva-managed datasets, default provider is `corva`.
7. Confirm app root path (folder that contains `package.json` with a `start` script).

## Preflight (run before any planning/code and after each iteration)

Run this exact sequence:
1. MCP health: `mcp__corva_ui__get_diagnostics`
If failing, run bootstrap flow and require restart (section below), then retry diagnostics.
2. Local token check: verify `<app-root>/.env.local` exists and contains `CORVA_BEARER_TOKEN`.
3. Context check: ensure `environment`, `provider`, `asset_id`, and `goal_intent` are known, and `collection` is resolved or in discovery flow.
4. If an iteration fetched samples, verify field summary was presented and any no-data state was explicitly reported.
5. Runtime check: verify FE dev server is running. If not running, start it with `yarn start` from app root.
6. Layout fit check (when UI changed): verify bottom content is reachable and app either fits widget bounds or scrolls inside app content.
7. Styling compliance check (when UI/styling changed): verify colors, typography, and spacing use Corva theme tokens or `@corva/ui` defaults; avoid ad-hoc palettes and hardcoded brand colors unless the user explicitly requested them.

If any preflight check fails, stop codegen and ask one short question to unblock.

## Runtime Server Rule (mandatory)

Once actual app building starts:
1. Start the FE server from app root with `yarn start`.
2. Detect and record the local app URL from logs (fallback `http://localhost:3000`).
3. On first local run (or if session is unauthenticated), tell the user to sign in to Corva at `https://app.local.corva.ai` with their credentials.
4. Always tell the user exactly how to open the app:
- open the URL in a browser
- keep terminal session running for live reload
5. On every next iteration:
- check if server is still responding on the recorded URL
- if not, run `yarn start` again and report that it was restarted
6. The user should not need to start the server manually.

## UI Layout Reference (mandatory)

Before any UI implementation or CSS/layout edits, read:
- `references/frontend-layout-guardrails.md`

Use that file as the source of truth for fit-to-widget, scroll ownership, and chart/table sizing behavior.

### Mandatory First-Question Flow (one-at-a-time)

Before any planning/coding work, ask setup questions one by one in this order.
Do not ask the next question until the current one is answered.

1. Ask: `Step 1/5: What is the asset_id for the target well/asset?`
2. Ask: `Step 2/5: Please confirm .env.local exists in the app root and includes CORVA_BEARER_TOKEN (yes/no).`
If answer is `no` or `unsure`, show:

```bash
CORVA_BEARER_TOKEN=eyJhbGciOi...your_token_here...
```

Then ask: `Please reply "ready" after this is set.`
3. Ask: `Step 3/5: Which provider should we use? If this is a Corva dataset, reply corva.`
4. Ask: `Step 4/5: Which environment should we use (qa or prod)?`
5. Ask: `Step 5/5: In plain language, what should this app show (for example frac stages, pump rate trend, or pressure vs time)?`

Do not ask users to name collection IDs by default.
Only ask for a collection name if the user already provided one, or if clarification is required after intent mapping.

If `asset_id` or token is missing, state this as a separate short note:
`We can still continue, but without asset_id and token we cannot fetch real samples yet, so field mapping will be inferred for now.`

## Required Context Gate (before codegen)

Collect and confirm all of these first:
1. `environment` (for example QA/Prod and concrete base URLs)
2. `provider`
3. `asset_id`
4. `goal_intent` (plain-language description of the chart/widget outcome)
5. `collection` resolved (provided by user or inferred from intent mapping)

If any item is missing, stop and request it. Do not generate app code until the gate is complete.

When requesting missing context, ask exactly one question for the highest-priority missing item in this order:
1. `asset_id`
2. token presence in `.env.local`
3. `provider`
4. `environment`
5. `goal_intent`

## Guided Setup Message Format (mandatory)

When required setup/context is incomplete, every assistant response must follow this format:
1. One short progress line (for example `Step 2/5`).
2. Exactly one question.
3. Optional helper note only when needed (single sentence, or token template code block).
4. Friendly tone line is optional, but if used, keep it to one short sentence.

Do not include full context recap, iteration status block, endpoint plan, or runtime URL while setup/context is incomplete.
Keep onboarding messages compact (target: 2-6 lines excluding code block).

### Guided Discovery Mode

If the user does not know `environment` and/or `asset_id`, do not fail the interaction.

Do this instead:
1. Ask only the minimum follow-up questions, one at a time:
- which segment (`completions` or `drilling`)
- which environment (`qa` or `prod`)
2. Map user intent (what chart/widget they want) to 1-3 concrete collection options from `docs/codex-optimized/datasets.json` (repo root) for that segment.
3. Select the best-fit collection internally based on user intent.
Only ask the user to choose between options when confidence is low or multiple options are equally strong.
4. Ask for provider. If it is a Corva dataset, default to `corva`. If unknown, ask for source/company name.
5. Ask for the target asset (asset id or asset name to resolve).
If asset cannot be resolved to `asset_id`, continue planning only and clearly mark data fields as inferred/guessed.
6. After context is complete, continue normal workflow and codegen.

Do not generate app code before the context gate is complete.

## Corva UI MCP Bootstrap (Required)

Before any `@corva/ui` MCP usage, run this gate:

1. Health check first:
- call `mcp__corva_ui__get_diagnostics`
- if it succeeds, continue

2. If health check fails or times out:
- ensure `@corva/ui` is installed in the workspace
- run:
  - `npx -p @corva/ui corva-ui-mcp-setup`
- then normalize MCP config to avoid npx handshake delays:
  - `.mcp.json` / `.cursor/mcp.json`:
    - `"command": "<workspace>/node_modules/.bin/corva-ui-mcp"`
  - `.codex/config.toml`:
    - `[mcp_servers.corva_ui]`
    - `command = "<workspace>/node_modules/.bin/corva-ui-mcp"`

3. Tell the user restart is required:
- If MCP config changed, ask for a full Codex app restart.
- After restart, re-run `mcp__corva_ui__get_diagnostics`.

4. Usage rules:
- Do not rely on generic MCP `resources/list` for `corva_ui`.
- Use Corva MCP tools directly:
  - `list_corva_ui`
  - `search_corva_ui`
  - `get_component_docs`
  - `get_hook_docs`
  - `get_client_docs`
  - `get_diagnostics`
5. After each iteration, re-run `mcp__corva_ui__get_diagnostics`.
If diagnostics fail mid-session, bootstrap again before continuing.

## MCP Prompt Template (copy/paste)

Use MCP bootstrap gate before doing any Corva UI work:
1) Run get_diagnostics for corva_ui.
2) If unavailable/timed out, install/configure MCP and switch command to local binary (node_modules/.bin/corva-ui-mcp), then tell the user to restart Codex.
3) After restart, verify get_diagnostics again.
4) Then continue using list/search/get_* docs tools.
Do not use resources/list for corva_ui.

## Workflow

1. Confirm app skeleton from bundled reference patterns.
Use `references/app_patterns_from_repo.md` and `references/vibe_apps_working_patterns.md`.
Do not require local demo/example apps; apply these patterns directly.

2. Resolve `@corva/ui` MCP usage from local implementation.
Use `references/mcp_usage_from_repo.md`.
Retrieve theme/component guidance for planned UI before styling decisions.

3. Pick collection candidates from codex-optimized metadata first.
Use `docs/codex-optimized/datasets.json` (repo root) via guidance in `references/data_api_get_catalog.md`.

4. Build request plan with asset-first queries.
Use `references/client_method_to_endpoint_map.md`.

5. Validate route truth from local APIs.
Use:
- `references/data_api_get_catalog.md`
- `references/platform_api_get_catalog.md`

6. If documentation/field coverage is weak, fetch real samples locally.
Use `references/local_data_sampling_fallback.md`.
After fetching samples, always show the user what fields/data are available, field by field, and explain what each field represents.
If a field meaning is inferred (not explicitly documented), label it as inferred.
If fetched sample records are empty, explicitly tell the user there is no data for the selected query context.

7. Enforce local token safety rules.
Use `references/security_local_token_rules.md`.
Keep `.env.local` minimal: token only.

8. Start/verify FE runtime server and provide open-app instructions.
Use the Runtime Server Rule above on every iteration.
9. For UI/layout tasks, apply `references/frontend-layout-guardrails.md` before writing code.
10. For UI/styling tasks, run a Corva styling compliance pass before finalizing:
- verify theme tokens are used for palette choices
- verify `@corva/ui` components are used where applicable
- replace custom colors if an equivalent Corva token exists

## Hard Rules

- MCP-first rule: use Corva UI MCP for component/styling/theme/color guidance before local guessing.
- Corva styling rule: app styling must follow Corva theme tokens and `@corva/ui` patterns by default.
- Always call `get_theme_docs` before choosing chart/app color schemes.
- Do not ship custom hex/rgb/hsl brand palettes when an equivalent Corva token exists.
- If a user reports styling mismatch, pause new feature work, run MCP theme/component checks, and patch styling compliance first.
- If real samples are fetched, always run field inference and report field availability to the user with field-by-field meaning/explanation.
- For each reported field, include a meaning confidence label: `documented` or `inferred`.
- If real sample fetch returns zero records, explicitly state: `No data was found for this collection and asset in the selected environment.`
- Query indexed collections with `asset_id` first.
- Default query shape for Data API reads: `query={"asset_id": <id>}` plus explicit sort/limit.
- Verify if the target dataset uses alternate keying (for example `metadata.asset_id`) before finalizing query shape.
- Keep API method/endpoint mapping aligned with `corva-ui/src/clients/jsonApi/index.js` and `corva-ui/src/clients/api/apiCore.js` (repo root).
- Prefer `corvaDataAPI` for `/api/v1/data/...` calls.

## MCP Quick Use

For `@corva/ui` discovery, run these in order:
1. `list_corva_ui` (targeted type)
2. `search_corva_ui` (narrow by query/type)
3. `get_component_docs` / `get_hook_docs` / `get_client_docs` as needed
4. `get_theme_docs` (mandatory for any UI/styling/color work) or `get_constants_docs` when styling/constants are required

Tool names and schemas are sourced from:
- `corva-ui/mcp-server/src/server/tools/index.ts` (repo root)
- `corva-ui/mcp-server/src/server/tools/*.ts` (repo root)

## Codegen Quality Gate (must pass)

Do not generate app code until all are true:
1. MCP diagnostics passing for current iteration.
2. Context gate complete (`environment`, `provider`, `asset_id`, `goal_intent`) and `collection` is resolved (user-provided or inferred), or discovery mode is explicitly marked.
3. Endpoint plan references route-truth catalogs.
4. Query shape validated (or marked provisional) for `asset_id` vs `metadata.asset_id`.
5. If sampling attempted, field summary is shown with field-by-field explanations and no-data case handled.
6. Layout fit gate passes for current UI: app content is not clipped at bottom in widget mode, or internal scrolling is available and verified.
7. Corva styling gate passes for current UI: palette/typography/spacing follow Corva theme tokens or `@corva/ui` defaults, and any overrides are explicitly justified.

## Output Expectations When This Skill Is Used

When setup/context is incomplete, produce only:
1. Step line (`Step X/Y`).
2. Exactly one question.
3. Optional helper note (single sentence or short token template).
4. Optional short friendly acknowledgment.

After context gate is complete, produce:
1. Context recap (`environment`, `provider`, `asset_id`, `goal_intent`, `collection` [provided/inferred])
2. Endpoint plan (data + platform metadata)
3. Data hook plan (initial fetch + realtime subscription)
4. Field availability + meaning summary when real samples were fetched:
- flattened field path
- inferred/documented meaning in plain language
- presence ratio
- inferred types
- nullability
- optional example value (if safe/helpful)
5. Risk notes when schema confidence is weak (missing fields, low sample coverage, ambiguous key path, or many `inferred` meanings)
6. Iteration status line (single compact line): `MCP=<pass/fail> | Token=<present/missing> | asset_id=<known/missing> | sample=<not-run/has-data/no-data> | server=<running/restarted/not-running> | layout=<pass/fail>`
7. Exactly one next user question (guided mode).
8. If server is running, provide open-app instruction with the local URL.
9. On first local run (or unauthenticated session), include a login reminder: `Please sign in at https://app.local.corva.ai before using the local app.`
10. Styling compliance note for UI changes:
- Corva theme tokens/components used
- any overrides and why they were needed

## References

- `references/app_patterns_from_repo.md`
- `references/mcp_usage_from_repo.md`
- `references/data_api_get_catalog.md`
- `references/platform_api_get_catalog.md`
- `references/client_method_to_endpoint_map.md`
- `references/vibe_apps_working_patterns.md`
- `references/local_data_sampling_fallback.md`
- `references/security_local_token_rules.md`
- `references/frontend-layout-guardrails.md`
