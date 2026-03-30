#!/bin/bash
# Builds agent-specific contract files from shared AGENT.md
# + per-adapter overlays.
#
# Usage: bash bin/build-contracts.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
AGENT="$REPO_ROOT/AGENT.md"
BUILT=0

build() {
  local overlay="$1" output="$2"
  local result
  result="$(cat "$AGENT" "$overlay")"

  if [ "$(cat "$output" 2>/dev/null)" != "$result" ]; then
    printf '%s\n' "$result" > "$output"
    BUILT=$((BUILT + 1))
  fi
}

# Claude
build "$REPO_ROOT/adapters/claude/overlay.md" \
      "$REPO_ROOT/adapters/claude/CLAUDE.example.md"

# Codex
build "$REPO_ROOT/adapters/codex/overlay.md" \
      "$REPO_ROOT/adapters/codex/CODEX.example.md"

if [ "$BUILT" -gt 0 ]; then
  echo "build-contracts: built $BUILT contract(s)"
else
  echo "build-contracts: all contracts up to date"
fi
