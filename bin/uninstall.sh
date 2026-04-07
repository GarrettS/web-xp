#!/usr/bin/env bash
# Removes a Web XP install from the current user's machine.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILLS_GLOB="${HOME}/.claude/skills/web-xp*"
CODEX_SKILLS_GLOB="${HOME}/.agents/skills/web-xp*"

print_plan() {
  cat <<EOF
This will remove:
- ${CLAUDE_SKILLS_GLOB}
- ${CODEX_SKILLS_GLOB}
- ${WEB_XP_DIR}
EOF
}

confirm() {
  local reply
  printf 'Continue uninstall? [y/N] '
  read -r reply || reply=""
  case "$reply" in
    y|Y|yes|YES)
      return 0
      ;;
    *)
      echo "Uninstall cancelled."
      return 1
      ;;
  esac
}

remove_matches() {
  local pattern="$1"
  shopt -s nullglob
  local matches=( $pattern )
  shopt -u nullglob

  if [ "${#matches[@]}" -eq 0 ]; then
    return 0
  fi

  rm -rf "${matches[@]}"
}

print_plan

if ! confirm; then
  exit 0
fi

remove_matches "$CLAUDE_SKILLS_GLOB"
remove_matches "$CODEX_SKILLS_GLOB"
rm -rf "$WEB_XP_DIR"

echo "Web XP was removed from this machine."
echo "Project agent files (CLAUDE.md, CODEX.md) are not removed. Run web-xp-off in each project to clean those up."
