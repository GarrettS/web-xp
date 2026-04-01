#!/usr/bin/env bash
# Internal maintainer tooling in the Web XP checkout (`~/.web-xp`).
# Not copied into consuming project repos.
# Syncs canonical sources → local `.claude/skills/` copies for repo-local
# Claude development only.
#
# Canonical sources:
# - repo root for shared standards/checks
# - adapters/claude/ for Claude skill source
#
# Direction: canonical source → `.claude/skills/`, never the reverse.
# Edits to `.claude/skills/` copies will be silently overwritten by this sync.

REPO_ROOT="$(git rev-parse --show-toplevel)"

# source:destination:comment-style
# md = HTML comment, sh = shell comment
STANDARD_PAIRS=(
  "code-guidelines.md:.claude/skills/code-guidelines.md:md"
  "code-philosophy.md:.claude/skills/code-philosophy.md:md"
  "bin/pre-commit-check.sh:.claude/skills/pre-commit-check.sh:sh"
)

SKILL_NAMES=(
  "web-xp"
  "web-xp-check"
  "web-xp-review"
  "web-xp-apply"
  "web-xp-init"
  "web-xp-on"
  "web-xp-off"
)

SYNCED=0

inject_and_copy() {
  local src="$1" dest="$2" style="$3" name
  name="${src##*/}"

  if [ "$style" = "md" ]; then
    printf '<!-- DO NOT EDIT — canonical source is /%s at repo root.\n' "$name"
    printf '     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->\n\n'
    cat "$src"
  else
    # Preserve shebang on first line, inject comment after it
    head -1 "$src"
    printf '# DO NOT EDIT — canonical source is /%s at repo root.\n' "bin/$name"
    printf '# This copy is auto-synced by the pre-commit hook. Edits here will be overwritten.\n#\n'
    tail -n +2 "$src"
  fi
}

inject_skill_header() {
  local src="$1" skill_name="$2"
  local header

  header="$(printf '<!-- DO NOT EDIT — canonical source is /adapters/claude/%s/SKILL.md.\n' "$skill_name")"
  header+="$(printf '     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->\n\n')"

  if [ "$(head -1 "$src")" = "---" ]; then
    awk -v injected="$header" '
      BEGIN { frontmatter_closed = 0; delimiter_count = 0 }
      {
        print
        if (!frontmatter_closed && $0 == "---") {
          delimiter_count++
          if (delimiter_count == 2) {
            printf "%s", injected
            frontmatter_closed = 1
          }
        }
      }
    ' "$src"
    return
  fi

  printf '%s' "$header"
  cat "$src"
}

for pair in "${STANDARD_PAIRS[@]}"; do
  IFS=':' read -r REL_SRC REL_DEST STYLE <<< "$pair"
  SRC="${REPO_ROOT}/${REL_SRC}"
  DEST="${REPO_ROOT}/${REL_DEST}"

  INJECTED="$(inject_and_copy "$SRC" "$DEST" "$STYLE")"
  if [ "$(cat "$DEST" 2>/dev/null)" != "$INJECTED" ]; then
    mkdir -p "$(dirname "$DEST")"
    printf '%s\n' "$INJECTED" > "$DEST"
    git add "$DEST"
    SYNCED=$((SYNCED + 1))
  fi
done

for skill_name in "${SKILL_NAMES[@]}"; do
  SRC="${REPO_ROOT}/adapters/claude/${skill_name}/SKILL.md"
  DEST="${REPO_ROOT}/.claude/skills/${skill_name}/SKILL.md"
  INJECTED="$(inject_skill_header "$SRC" "$skill_name")"
  if [ "$(cat "$DEST" 2>/dev/null)" != "$INJECTED" ]; then
    mkdir -p "$(dirname "$DEST")"
    printf '%s\n' "$INJECTED" > "$DEST"
    git add "$DEST"
    SYNCED=$((SYNCED + 1))
  fi
done

if [ "$SYNCED" -gt 0 ]; then
  echo "check-web-xp-sync: copied $SYNCED file(s) into .claude/skills/"
fi

exit 0
