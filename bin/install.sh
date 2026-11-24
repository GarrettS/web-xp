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
  "editorial-rules.md"
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
rm -rf "${CLAUDE_SKILLS_DEST}/web-xp-init" "${CLAUDE_SKILLS_DEST}/web-xp-remove" "${CLAUDE_SKILLS_DEST}/web-xp-apply"
for skill_path in "$CLAUDE_SKILLS_SRC"/web-xp*/; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CLAUDE_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CLAUDE_SKILLS_DEST}/${skill_name}"
done
rm -rf "${CLAUDE_SKILLS_DEST}/web-xp-init" "${CLAUDE_SKILLS_DEST}/web-xp-remove" "${CLAUDE_SKILLS_DEST}/web-xp-apply"
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
rm -rf "${CODEX_SKILLS_DEST}/web-xp-init" "${CODEX_SKILLS_DEST}/web-xp-remove" "${CODEX_SKILLS_DEST}/web-xp-apply"
for skill_path in "$CODEX_SKILLS_SRC"/*; do
  skill_name="$(basename "$skill_path")"
  rm -rf "${CODEX_SKILLS_DEST}/${skill_name}"
  cp -r "$skill_path" "${CODEX_SKILLS_DEST}/${skill_name}"
done
rm -rf "${CODEX_SKILLS_DEST}/web-xp-init" "${CODEX_SKILLS_DEST}/web-xp-remove" "${CODEX_SKILLS_DEST}/web-xp-apply"

# Record the installed commit and date next to the installed standard, so agents
# can see the standard's real currency. WEB_XP_VERSION is a release label, not a
# content date, and must not be read as one.
install_info="${CLAUDE_SKILLS_DEST}/.web-xp-install-info"
{
  if git -C "$WEB_XP_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    printf 'installed-commit: %s\n' "$(git -C "$WEB_XP_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf 'installed-commit-date: %s\n' "$(git -C "$WEB_XP_DIR" log -1 --format=%ci 2>/dev/null)"
  fi
  printf 'installed-at: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
} > "$install_info" 2>/dev/null || true
append_manifest_path "$install_info"

write_manifest

echo "Claude skills installed to ${CLAUDE_SKILLS_DEST}"
echo "Codex skills installed to ${CODEX_SKILLS_DEST}"

# --- Review Workflow Loop Stop hook ---
# Register the Stop hook in Claude settings so the loop is enforced. Idempotent,
# backs the settings file up first, and only registers when the hook script is
# actually present — so a registration can never point at a missing file and
# error on every turn.
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"
STOP_HOOK_SCRIPT="${HOME}/.web-xp/tools/review-stop-hook.sh"
STOP_HOOK_CMD="bash ${STOP_HOOK_SCRIPT}"

register_stop_hook() {
  local settings="$CLAUDE_SETTINGS" cmd="$STOP_HOOK_CMD" tmp
  if [ ! -f "$STOP_HOOK_SCRIPT" ]; then
    echo "note: ${STOP_HOOK_SCRIPT} not found — skipping hook registration (clone Web XP to ~/.web-xp)."
    return 0
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "note: jq not found — add the review Stop hook to ${settings} by hand (see tools/code-loop.md)."
    return 0
  fi
  mkdir -p "$(dirname "$settings")"
  [ -f "$settings" ] || printf '{}\n' > "$settings"
  if jq -e --arg c "$cmd" '[.hooks.Stop[]?.hooks[]?.command] | index($c) != null' "$settings" >/dev/null 2>&1; then
    echo "Review Stop hook already registered in ${settings}"
    return 0
  fi
  tmp="$(mktemp)"
  if jq --arg c "$cmd" '.hooks.Stop = ((.hooks.Stop // []) + [{hooks: [{type: "command", command: $c}]}])' "$settings" > "$tmp"; then
    cp "$settings" "${settings}.web-xp-backup"
    mv "$tmp" "$settings"
    echo "Registered the Web XP review Stop hook in ${settings} (backup: ${settings}.web-xp-backup)"
  else
    rm -f "$tmp"
    echo "warning: could not register the review Stop hook in ${settings}; add it by hand (see tools/code-loop.md)." >&2
  fi
  return 0
}

register_stop_hook

# Report whether the loop can actually run, so a fresh install is not a mystery.
if command -v codex >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  echo "Review Workflow Loop: active (codex and jq found)."
else
  loop_missing=""
  command -v codex >/dev/null 2>&1 || loop_missing="codex"
  command -v jq >/dev/null 2>&1 || loop_missing="${loop_missing:+$loop_missing, }jq"
  echo "Review Workflow Loop: dormant until you install: ${loop_missing}. The Stop hook stays a silent no-op until then."
fi
