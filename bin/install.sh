#!/usr/bin/env bash
# Post-clone / post-pull install for Web XP.
# Copies skill files and standards into agent discovery directories.

set -euo pipefail

WEB_XP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_PATH="${WEB_XP_MANIFEST_PATH:-${WEB_XP_DIR}/web-xp-manifest.txt}"
MANIFEST_HEADER="# web-xp-manifest-v1"

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

desired_files_tmp="$(mktemp)"
previous_files_tmp="$(mktemp)"
trap 'rm -f "$desired_files_tmp" "$previous_files_tmp"' EXIT

append_manifest_path() {
  printf '%s\n' "$1" >> "$desired_files_tmp"
}

track_skill_files() {
  local src_dir="$1"
  local dest_dir="$2"

  while IFS= read -r src_file; do
    local rel_path
    rel_path="${src_file#$src_dir/}"
    append_manifest_path "$dest_dir/$rel_path"
  done < <(find "$src_dir" -type f | sort)
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

remove_stale_managed_paths() {
  local stale_path

  while IFS= read -r stale_path; do
    [ -n "$stale_path" ] || continue
    rm -f "$stale_path"

    case "$stale_path" in
      "$CLAUDE_SKILLS_DEST"/*)
        prune_empty_parent_dirs "$stale_path" "$CLAUDE_SKILLS_DEST"
        ;;
      "$CODEX_SKILLS_DEST"/*)
        prune_empty_parent_dirs "$stale_path" "$CODEX_SKILLS_DEST"
        ;;
    esac
  done < <(grep -Fvx -f "$desired_files_tmp" "$previous_files_tmp" || true)
}

write_manifest() {
  local tmp_manifest
  tmp_manifest="$(mktemp)"

  {
    printf '%s\n' "$MANIFEST_HEADER"
    sort -u "$desired_files_tmp"
  } > "$tmp_manifest"

  mv "$tmp_manifest" "$MANIFEST_PATH"
}

if [ ! -d "$CLAUDE_SKILLS_SRC" ]; then
  echo "error: Claude skill source not found at ${CLAUDE_SKILLS_SRC}" >&2
  exit 1
fi

if [ ! -d "$CODEX_SKILLS_SRC" ]; then
  echo "error: Codex skill source not found at ${CODEX_SKILLS_SRC}" >&2
  exit 1
fi

for skill_path in "$CLAUDE_SKILLS_SRC"/web-xp*/; do
  track_skill_files "$skill_path" "$CLAUDE_SKILLS_DEST/$(basename "$skill_path")"
done
for standards_file in "${STANDARDS_FILES[@]}"; do
  append_manifest_path "$CLAUDE_SKILLS_DEST/${standards_file}"
done
append_manifest_path "$CLAUDE_SKILLS_DEST/pre-commit-check.sh"

for skill_path in "$CODEX_SKILLS_SRC"/*; do
  track_skill_files "$skill_path" "$CODEX_SKILLS_DEST/$(basename "$skill_path")"
done

read_manifest_paths | sort -u > "$previous_files_tmp"
remove_stale_managed_paths

# Claude: clean previous Web XP install, then copy fresh
mkdir -p "$CLAUDE_SKILLS_DEST"
rm -rf "${CLAUDE_SKILLS_DEST}/web-xp-init" "${CLAUDE_SKILLS_DEST}/web-xp-remove"
for skill_path in "$CLAUDE_SKILLS_SRC"/web-xp*/; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CLAUDE_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CLAUDE_SKILLS_DEST}/${skill_name}"
done
rm -rf "${CLAUDE_SKILLS_DEST}/web-xp-init" "${CLAUDE_SKILLS_DEST}/web-xp-remove"
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
rm -rf "${CODEX_SKILLS_DEST}/web-xp-init" "${CODEX_SKILLS_DEST}/web-xp-remove"
for skill_path in "$CODEX_SKILLS_SRC"/*; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CODEX_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CODEX_SKILLS_DEST}/${skill_name}"
done
rm -rf "${CODEX_SKILLS_DEST}/web-xp-init" "${CODEX_SKILLS_DEST}/web-xp-remove"

write_manifest

echo "Claude skills installed to ${CLAUDE_SKILLS_DEST}"
echo "Codex skills installed to ${CODEX_SKILLS_DEST}"
