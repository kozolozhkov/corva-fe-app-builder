# Corva FE App Builder Skill

An open-format Agent Skill to scaffold and iterate Corva FE apps with a real-data-first workflow.

## Open Format Notes

- follows the Agent Skills structure commonly used on [skills.sh](https://skills.sh)
- keeps required entrypoint in `SKILL.md` with `name` + `description` frontmatter
- stores procedural depth in `references/` and deterministic utilities in `scripts/`
- keeps host metadata (`agents/openai.yaml`) optional so non-OpenAI hosts can ignore it

## What This Skill Optimizes For

- early `asset_id` capture and real-data sampling when available
- inferred fallback scaffolding when `asset_id` or token is missing
- explicit confidence labeling (`sampled` vs `inferred`)
- reusable scripts for preflight, runtime, and sampling

## Unified Flow

1. capture goal intent
2. ask/confirm `asset_id`
3. verify local `.env.local` token setup (`CORVA_BEARER_TOKEN`)
4. infer collection from intent (ask options only when confidence is low)
5. attempt real sampling immediately when token + `asset_id` are available
6. scaffold/build with `sampled` or `inferred` confidence labeling
7. start or restart local server and report URL/status
8. provide next unblock step if sampling was skipped

Default behavior:

- provider defaults to `corva`
- environment defaults to `prod`
- codegen is allowed when token and/or `asset_id` is missing, but mapping must be labeled `inferred`
- token handling is local-file only: never ask users to paste tokens in chat

## First-Time Install Checklist (required)

1. Install the skill in your host skill directory.
2. Run MCP bootstrap in the target workspace:

```bash
<skill-root>/scripts/bootstrap_corva_ui_mcp.sh --workspace <workspace>
```

3. Restart host (Codex/Claude Code/Cursor).
4. Verify Corva MCP tools are visible and diagnostics pass.
5. On first build iteration, ensure runtime is started with:

```bash
<skill-root>/scripts/start_or_restart_dev.sh --app-root <app-root>
```

## Use In Hosts

```text
# Codex
$corva-fe-app-builder

# Claude Code
$corva-fe-app-builder
```

## Install

Place this folder in your host skill directory:

- Codex: `$CODEX_HOME/skills/corva-fe-app-builder`
- Claude Code: `~/.claude/skills/corva-fe-app-builder`
- Other Agent Skills hosts: host-specific skills directory

Codex helper install command:

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

python3 "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url "https://github.com/<org-or-user>/<repo>/tree/main/<path>/corva-fe-app-builder"
```

Restart your host after installation or updates.

## Script Quickstart

```bash
# bootstrap MCP for first-time workspace setup
<skill-root>/scripts/bootstrap_corva_ui_mcp.sh --workspace <workspace>

# preflight
<skill-root>/scripts/preflight.sh --app-root <app-root>

# compatibility strict preflight (--strict preserved)
<skill-root>/scripts/preflight.sh \
  --strict \
  --app-root <app-root> \
  --asset-id <asset_id> \
  --goal-intent "<goal>" \
  --collection <collection>

# ensure local dev server is running
<skill-root>/scripts/start_or_restart_dev.sh --app-root <app-root>

# fetch real sample + field summary
<skill-root>/scripts/sample_data.js \
  --app-root <app-root> \
  --base-url <data_api_base_url> \
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
│   ├── bootstrap_corva_ui_mcp.sh
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
2. Run skill validation (example for Codex environments):

```bash
python3 "$CODEX_HOME/skills/.system/skill-creator/scripts/quick_validate.py" \
  "$CODEX_HOME/skills/corva-fe-app-builder"
```

3. Commit and push changes.
4. Reinstall/update skill copy and restart your host.
