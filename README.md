# Corva FE App Builder Skill

A Codex skill for planning and scaffolding Corva FE apps with:

- MCP-first `@corva/ui` guidance
- strict preflight and quality gates
- one-question-at-a-time guided setup
- collection mapping from natural-language intent
- real sample validation with field-by-field summaries
- enforced Corva styling compliance (theme tokens/components)

## What This Skill Is For

Use this skill when you want Codex to build or iterate Corva FE apps in a consistent, production-oriented way, especially for:

- data-driven chart widgets
- realtime + historical data flows
- schema validation against sample data
- style compliance with Corva UI theme standards

## Install In Codex

Install from GitHub using the built-in skill installer:

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

python3 "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url "https://github.com/<org-or-user>/<repo>/tree/main/<path>/corva-fe-app-builder"
```

Restart Codex after installation.

## Usage

In Codex, invoke:

```text
$corva-fe-app-builder
```

## Repository Structure

```text
corva-fe-app-builder/
├── SKILL.md                           # Skill contract and workflow (source of truth)
├── agents/openai.yaml                 # Skill metadata for UI
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
│   └── dataset_descriptions/
│       ├── README.md
│       └── datasets.json
├── scripts/
│   ├── fetch_samples_with_env_token.sh
│   ├── infer_field_presence.js
│   ├── list_data_api_get_endpoints.sh
│   └── list_platform_get_endpoints.sh
└── assets/
    ├── small-icon.png
    └── large-icon.png
```

## Path Placeholders Used In Docs

- `<app-root>`: target FE app folder (contains `package.json` and `.env.local`)
- `<skill-root>`: installed `corva-fe-app-builder` folder

## Updating The Skill

1. Edit `SKILL.md` and related files in `references/` and `scripts/`.
2. Commit and push.
3. Teammates reinstall the skill from GitHub (or update local copy) and restart Codex.

## Notes

- This skill is designed to work even when local demo/example apps are not available.
- Bundled dataset metadata lives in `references/dataset_descriptions/datasets.json` and is used as the primary intent-to-collection mapping source.
