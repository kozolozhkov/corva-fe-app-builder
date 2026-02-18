# Security: Local Token Rules

Apply these rules for any local sample fetching flow.

## Mandatory Rules

1. Store token only in `.env.local`.
2. Ensure `.env.local` is gitignored.
3. Restrict file permissions: `chmod 600 <app-root>/.env.local`.
4. Use short-lived bearer tokens.
5. Never print or log token values.
6. Never ask users to paste token values in chat; ask them to edit `.env.local` locally and reply `ready`.

## Safe Execution Pattern

```bash
set -a
source <app-root>/.env.local
set +a

CORVA_DATA_API_BASE_URL="https://data-api.qa.cloud.corva.ai" \
CORVA_PROVIDER="corva" \
CORVA_COLLECTION="wits.summary-6h" \
CORVA_ASSET_ID="12345" \
<skill-root>/scripts/fetch_samples_with_env_token.sh > /tmp/corva_samples.json
```

Only keep the token in `.env.local`. Pass non-secret runtime values inline.

## Prohibited

- Do not commit token-bearing files.
- Do not paste token values into chat output.
- Do not ask users to send token values over chat.
- Do not run commands with shell tracing (`set -x`) when auth headers are present.
