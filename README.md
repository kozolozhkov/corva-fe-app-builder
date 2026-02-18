# Corva FE App Builder Skill

A Codex skill to scaffold and iterate Corva FE apps quickly, then harden when needed.

## What This Skill Optimizes For

- fast app bootstrap with `@corva/ui` defaults
- optional real-data wiring and schema checks
- optional strict hardening before handoff
- reusable scripts for preflight, runtime, and sampling

## Operating Modes

1. `fast-start` (default): scaffold UI, use mock data when needed, start local app.
2. `real-data`: resolve provider/collection/asset and validate with sample fetches.
3. `hardening`: run strict preflight and styling/layout compliance checks.

## Use In Codex

```text
$corva-fe-app-builder
```

## Install In Codex

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

python3 "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url "https://github.com/<org-or-user>/<repo>/tree/main/<path>/corva-fe-app-builder"
```

Restart Codex after installation or updates.

## Script Quickstart

```bash
# quick preflight (fast-start compatible)
<skill-root>/scripts/preflight.sh --app-root <app-root>

# strict preflight (hardening)
<skill-root>/scripts/preflight.sh \
  --strict \
  --app-root <app-root> \
  --asset-id <asset_id> \
  --provider <provider> \
  --environment <qa|prod> \
  --goal-intent "<goal>" \
  --collection <collection>

# ensure local dev server is running
<skill-root>/scripts/start_or_restart_dev.sh --app-root <app-root>

# fetch real sample + field summary
<skill-root>/scripts/sample_data.js \
  --app-root <app-root> \
  --base-url <data_api_base_url> \
  --provider <provider> \
  --collection <collection> \
  --asset-id <asset_id>
```

## Repository Structure

```text
corva-fe-app-builder/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── app_scaffold_patterns.md
│   ├── data_hook_patterns.md
│   ├── mcp_usage.md
│   ├── data_api_get_catalog.md
│   ├── platform_api_get_catalog.md
│   ├── client_method_to_endpoint_map.md
│   ├── local_data_sampling_fallback.md
│   ├── security_local_token_rules.md
│   ├── frontend-layout-guardrails.md
│   ├── preflight-strict.md
│   ├── data-sampling.md
│   ├── styling-compliance.md
│   └── dataset_descriptions/
│       ├── README.md
│       └── datasets.json
├── scripts/
│   ├── preflight.sh
│   ├── start_or_restart_dev.sh
│   ├── sample_data.js
│   ├── fetch_samples_with_env_token.sh
│   ├── infer_field_presence.js
│   ├── list_data_api_get_endpoints.sh
│   └── list_platform_get_endpoints.sh
└── assets/
    ├── small-icon.png
    └── large-icon.png
```

## Path Placeholders

- `<app-root>`: target FE app folder (contains `package.json` and usually `.env.local`).
- `<skill-root>`: installed `corva-fe-app-builder` folder.

## Update Workflow

1. Edit `SKILL.md`, references, and scripts.
2. Run skill validation:

```bash
python3 "$CODEX_HOME/skills/.system/skill-creator/scripts/quick_validate.py" \
  "$CODEX_HOME/skills/corva-fe-app-builder"
```

3. Commit and push changes.
4. Reinstall/update skill copy and restart Codex.
