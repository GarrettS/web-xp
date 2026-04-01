#!/bin/bash
# Internal maintainer tooling in the Web XP checkout (`~/.web-xp`).
# Not run inside consuming project repos during normal Web XP use.
# Builds the shipped agent-specific contract templates from shared
# `AGENT.md` + per-adapter overlays.
#
# AGENT.md is the shared base contract — project-level rules that apply
# to every agent. This script concatenates it with each adapter's
# overlay.md to produce a built contract (e.g. CLAUDE.example.md).
# Because the build is plain concatenation (cat), anything in AGENT.md
# or overlay.md appears verbatim in the output. Do not put maintainer
# comments, build-chain docs, or internal notes in those files —
# they will leak into emitted project contracts.
#
# Usage: bash tools/build-contracts.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
AGENT="$REPO_ROOT/AGENT.md"
BUILT=0

build() {
  local overlay="$1" output="$2"
  local result
  result="$(printf '%s\n\n' '<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->'; cat "$AGENT" "$overlay"; printf '\n<!-- END WEB-XP -->\n')"

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
