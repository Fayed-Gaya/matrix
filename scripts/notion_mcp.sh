#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
NODE20_BIN="/usr/local/opt/node@20/bin"

if [[ -x "$NODE20_BIN/node" ]]; then
  export PATH="$NODE20_BIN:$PATH"
fi

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${NOTION_TOKEN:-}" ]]; then
  echo "NOTION_TOKEN is not set. Add it to $ENV_FILE or export it before starting Codex." >&2
  exit 1
fi

exec npx -y @notionhq/notion-mcp-server
