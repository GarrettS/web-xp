#!/usr/bin/env bash
# Post-clone / post-pull install for Web XP.
# Copies Claude skill files into ~/.claude/skills/.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${WEB_XP_DIR}/.claude/skills"
SKILLS_DEST="${HOME}/.claude/skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "error: skill source not found at ${SKILLS_SRC}" >&2
  exit 1
fi

mkdir -p "$SKILLS_DEST"
cp -r "$SKILLS_SRC"/* "$SKILLS_DEST"/

echo "Web XP skills installed to ${SKILLS_DEST}"
