# MCP Usage and Bootstrap

Use this when the workspace contains `corva-ui` source and MCP server files.

## Source Files
- Bundled MCP tool model in this skill (default)
- Optional source-workspace files if available

## Local Server Config In Repo

Repo config file:
`<workspace>/.mcp.json`

Bootstrap helper command (from README):
- `npx -p @corva/ui corva-ui-mcp-setup`

After setup, normalize MCP command to the local binary:
- `.mcp.json` / `.cursor/mcp.json`:
  - `"command": "<workspace>/node_modules/.bin/corva-ui-mcp"`
- `.codex/config.toml`:
  - `[mcp_servers.corva_ui]`
  - `command = "<workspace>/node_modules/.bin/corva-ui-mcp"`

Example (`.mcp.json`):
```json
{
  "mcpServers": {
    "corva-ui": {
      "command": "<workspace>/node_modules/.bin/corva-ui-mcp"
    }
  }
}
```

## Tool Catalog (Registered)

From `tools/index.ts` and server registration:

- `search_corva_ui`
- `get_component_docs`
- `get_hook_docs`
- `get_theme_docs`
- `list_corva_ui`
- `get_constants_docs`
- `get_client_docs`
- `get_diagnostics`

## Input Schema Summary

1. `search_corva_ui`
- required: `query`
- optional: `type` (`all|component|hook|util|constant|client|permission|icon|hoc|type|testing|style`)
- optional: `category` (`all|v2|v1`)
- optional: `limit`

2. `get_component_docs`
- required: `name`
- optional: `category` (`v2|v1`)

3. `get_hook_docs`
- required: `name`

4. `get_theme_docs`
- optional: `section` (`palette|variables|all`)

5. `list_corva_ui`
- required: `type` (`components-v2|components-v1|hooks|utils|constants|clients|permissions|icons|hocs|types|testing|styles`)

6. `get_constants_docs`
- required: `namespace` (namespace or constant name)

7. `get_client_docs`
- required: `name`
- optional: `tag`

8. `get_diagnostics`
- no input args

## Recommended MCP Discovery Sequence

1. `list_corva_ui` (target category)
2. `search_corva_ui` (term narrowing)
3. `get_component_docs` / `get_hook_docs` / `get_client_docs`
4. `get_theme_docs` / `get_constants_docs` if needed

## Server Health Bootstrap Gate

1. Call `mcp__corva_ui__get_diagnostics`.
2. If unavailable/timed out:
- ensure `@corva/ui` is installed
- run `npx -p @corva/ui corva-ui-mcp-setup`
- normalize configs to local binary command (`node_modules/.bin/corva-ui-mcp`)
The agent owns this recovery flow so the user does not need to manually start MCP.
3. If config changed, require full Codex restart.
4. After restart, call `mcp__corva_ui__get_diagnostics` again.
5. Repeat diagnostics check after each iteration.

## Usage Boundary

- Do not use generic MCP `resources/list` for `corva_ui`.
- Use Corva tools directly (`list_corva_ui`, `search_corva_ui`, `get_*_docs`, `get_diagnostics`).

## Notes

- README states MCP support is available from `@corva/ui` `3.44.0`.
- `get_client_docs` is the fastest way to inspect client methods + endpoint groupings before wiring data hooks.
- Full source-workspace files are optional; this guide is usable with only `<app-root>` + `<skill-root>`.
