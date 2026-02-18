# Dataset Catalog (Bundled)

This folder provides a bundled, LLM-friendly dataset catalog so the skill can work even when no local repo dataset docs are available.

## Files

- `datasets.json`: consolidated dataset metadata used for collection-intent mapping.

Each dataset entry includes:

- `group`: `drilling` or `completions`
- `title` and `desc`
- `freq`
- primary `keys`
- `fields`: flattened field path -> type abbreviation
- `doc`: source document path from the original dataset docs set

## Type Abbreviations

| Abbrev | Type |
|--------|------|
| `f` | float |
| `i` | int |
| `l` | long |
| `s` | string |
| `o` | object |
| `a` | array |
| `b` | boolean |

## Usage in Skill

- Use this catalog as the primary source to suggest candidate collections from user intent.
- If repo-level dataset docs are available, treat them as an optional cross-check source.
