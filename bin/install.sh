#!/usr/bin/env bash
# Post-clone / post-pull install for Web XP.
# Copies skill files and standards into agent discovery directories.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"

CLAUDE_SKILLS_SRC="${WEB_XP_DIR}/adapters/claude"
CLAUDE_SKILLS_DEST="${HOME}/.claude/skills"
CODEX_SKILLS_SRC="${WEB_XP_DIR}/adapters/codex/skills"
CODEX_SKILLS_DEST="${HOME}/.agents/skills"

# Standards files that Claude skills reference via ${CLAUDE_SKILL_DIR}/../
STANDARDS_FILES=(
  "code-guidelines.md"
  "code-philosophy.md"
)
PRECOMMIT_SRC="${WEB_XP_DIR}/bin/pre-commit-check.sh"

if [ ! -d "$CLAUDE_SKILLS_SRC" ]; then
  echo "error: Claude skill source not found at ${CLAUDE_SKILLS_SRC}" >&2
  exit 1
fi

if [ ! -d "$CODEX_SKILLS_SRC" ]; then
  echo "error: Codex skill source not found at ${CODEX_SKILLS_SRC}" >&2
  exit 1
fi

# Claude: clean previous Web XP install, then copy fresh
mkdir -p "$CLAUDE_SKILLS_DEST"
for skill_path in "$CLAUDE_SKILLS_SRC"/web-xp*/; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CLAUDE_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CLAUDE_SKILLS_DEST}/${skill_name}"
done
rm -f "$CLAUDE_SKILLS_DEST/code-guidelines.md" \
      "$CLAUDE_SKILLS_DEST/code-philosophy.md" \
      "$CLAUDE_SKILLS_DEST/pre-commit-check.sh"

# Claude: install standards files alongside skills
for standards_file in "${STANDARDS_FILES[@]}"; do
  cp "${WEB_XP_DIR}/${standards_file}" "${CLAUDE_SKILLS_DEST}/${standards_file}"
done
cp "$PRECOMMIT_SRC" "${CLAUDE_SKILLS_DEST}/pre-commit-check.sh"

# Codex: install skill directories (clean first, then copy)
mkdir -p "$CODEX_SKILLS_DEST"
for skill_path in "$CODEX_SKILLS_SRC"/*; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CODEX_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CODEX_SKILLS_DEST}/${skill_name}"
done

echo "Claude skills installed to ${CLAUDE_SKILLS_DEST}"
echo "Codex skills installed to ${CODEX_SKILLS_DEST}"
