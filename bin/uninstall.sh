#!/usr/bin/env bash
# Removes a Web XP install from the current user's machine.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_PATH="${WEB_XP_MANIFEST_PATH:-${WEB_XP_DIR}/web-xp-manifest.txt}"
CLAUDE_SKILLS_GLOB="${HOME}/.claude/skills/web-xp*"
CODEX_SKILLS_GLOB="${HOME}/.agents/skills/web-xp*"

print_plan() {
  echo "This will remove:"
  echo "- ${WEB_XP_DIR}"

  if [ -f "$MANIFEST_PATH" ]; then
    echo "- ${MANIFEST_PATH}"
    read_manifest_paths | while IFS= read -r manifest_path; do
      [ -n "$manifest_path" ] || continue
      echo "- ${manifest_path}"
    done
  else
    echo "- ${CLAUDE_SKILLS_GLOB}"
    echo "- ${CODEX_SKILLS_GLOB}"
  fi
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

read_manifest_paths() {
  if [ ! -f "$MANIFEST_PATH" ]; then
    return
  fi

  grep -v '^[[:space:]]*#' "$MANIFEST_PATH" | sed '/^[[:space:]]*$/d'
}

prune_empty_parent_dirs() {
  local target_path="$1"
  local root_dir="$2"
  local dir
  dir="$(dirname "$target_path")"

  while [ "$dir" != "$root_dir" ] && [ "${dir#"$root_dir"/}" != "$dir" ]; do
    rmdir "$dir" 2>/dev/null || break
    dir="$(dirname "$dir")"
  done
}

remove_manifest_paths() {
  local manifest_path

  while IFS= read -r manifest_path; do
    [ -n "$manifest_path" ] || continue
    rm -f "$manifest_path"

    case "$manifest_path" in
      "${HOME}/.claude/skills/"*)
        prune_empty_parent_dirs "$manifest_path" "${HOME}/.claude/skills"
        ;;
      "${HOME}/.agents/skills/"*)
        prune_empty_parent_dirs "$manifest_path" "${HOME}/.agents/skills"
        ;;
    esac
  done < <(read_manifest_paths)
}

print_plan

if ! confirm; then
  exit 0
fi

if [ -f "$MANIFEST_PATH" ]; then
  remove_manifest_paths
  rm -f "$MANIFEST_PATH"
else
  remove_matches "$CLAUDE_SKILLS_GLOB"
  remove_matches "$CODEX_SKILLS_GLOB"
fi
rm -rf "$WEB_XP_DIR"

echo "Web XP was removed from this machine."
echo "Project agent files (CLAUDE.md, CODEX.md) are not removed. Run web-xp-off in each project to clean those up."
