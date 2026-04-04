#!/usr/bin/env bash
# Post-clone / post-pull install for Web XP.
# Copies Web XP skill files into agent discovery directories.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${WEB_XP_DIR}/.claude/skills"
SKILLS_DEST="${HOME}/.claude/skills"
CODEX_SKILLS_SRC="${WEB_XP_DIR}/adapters/codex/skills"
CODEX_SKILLS_DEST="${HOME}/.agents/skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "error: skill source not found at ${SKILLS_SRC}" >&2
  exit 1
fi

if [ ! -d "$CODEX_SKILLS_SRC" ]; then
  echo "error: Codex skill source not found at ${CODEX_SKILLS_SRC}" >&2
  exit 1
fi

mkdir -p "$SKILLS_DEST"
cp -r "$SKILLS_SRC"/* "$SKILLS_DEST"/

mkdir -p "$CODEX_SKILLS_DEST"
for skill_path in "$CODEX_SKILLS_SRC"/*; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CODEX_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CODEX_SKILLS_DEST}/${skill_name}"
done

echo "Web XP skills installed to ${SKILLS_DEST}"
echo "Web XP bootstrap command available at ${WEB_XP_DIR}/bin/web-xp-init"
echo "Web XP project cleanup command available at ${WEB_XP_DIR}/bin/web-xp-remove"
echo "Codex skills installed to ${CODEX_SKILLS_DEST}"
