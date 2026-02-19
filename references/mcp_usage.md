# MCP Usage and Bootstrap

Use this when the workspace contains `corva-ui` source and MCP server files.

This reference is host-agnostic for Agent Skills hosts (Codex, Claude Code, Cursor, and similar tools).

## Source Files

- Bundled MCP tool model in this skill (default)
- Optional source-workspace files if available

## Tool Catalog (Registered)

- `search_corva_ui`
- `get_component_docs`
- `get_hook_docs`
- `get_theme_docs`
- `list_corva_ui`
- `get_constants_docs`
- `get_client_docs`
- `get_diagnostics`

## Host Alias Mapping

Use capability names first, then map to host aliases:

1. Diagnostics capability: `get_diagnostics`
- Codex alias: `mcp__corva_ui__get_diagnostics`
- Claude Code / other hosts: use alias for `corva_ui.get_diagnostics`
2. Catalog capability: `list_corva_ui`
3. Search capability: `search_corva_ui`
4. Docs capabilities: `get_component_docs`, `get_hook_docs`, `get_theme_docs`, `get_constants_docs`, `get_client_docs`

## First-Time Bootstrap (required)

If Corva MCP tools are missing from host tool list, run:

```bash
<skill-root>/scripts/bootstrap_corva_ui_mcp.sh --workspace <workspace>
```

This script:

1. runs `npx -p @corva/ui corva-ui-mcp-setup` (unless skipped)
2. writes `<workspace>/.mcp.json` with local command
3. writes `<workspace>/.cursor/mcp.json` with local command
4. updates `$CODEX_HOME/config.toml` (`mcp_servers.corva_ui.command`) when Codex config is available

After running, restart the host and re-check diagnostics.

## Workspace Config Shape

Expected command:

`<workspace>/node_modules/.bin/corva-ui-mcp`

Expected JSON shape (`.mcp.json` / `.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "corva-ui": {
      "command": "<workspace>/node_modules/.bin/corva-ui-mcp"
    }
  }
}
```

## Server Health Gate

1. Call diagnostics (`get_diagnostics`) with host alias.
2. If unavailable/timed out, run first-time bootstrap.
3. Restart host if config changed.
4. Call diagnostics again.
5. Repeat diagnostics check after each iteration.

## Usage Boundary

- Do not use generic MCP `resources/list` for `corva_ui`.
- Use Corva tools directly (`list_corva_ui`, `search_corva_ui`, `get_*_docs`, `get_diagnostics`).

## Notes

- `get_client_docs` is the fastest way to inspect client methods + endpoint groupings before wiring data hooks.
- Full source-workspace files are optional; this guide is usable with only `<app-root>` + `<skill-root>`.
