#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats >/dev/null 2>&1; then
  echo "error: bats is not installed. Install bats-core first (for example: brew install bats-core)." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec bats "$REPO_ROOT"/test/unit/*.bats
