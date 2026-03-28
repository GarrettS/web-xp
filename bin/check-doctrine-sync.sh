#!/usr/bin/env bash
# Internal to the code-guidelines repo. Not distributed to consuming projects.
# Syncs root doctrine files → .claude/skills/ copies with DO NOT EDIT headers.
#
# Direction: root → .claude/skills/, never the reverse.
# Root copies are canonical. Edits to the .claude/skills/ copies
# will be silently overwritten by this hook. If you want to change
# a doctrine file, edit the root copy.

REPO_ROOT="$(git rev-parse --show-toplevel)"

# source:destination:comment-style
# md = HTML comment, sh = shell comment
PAIRS=(
  "code-guidelines.md:.claude/skills/code-guidelines.md:md"
  "code-philosophy.md:.claude/skills/code-philosophy.md:md"
  "bin/pre-commit-check.sh:.claude/skills/pre-commit-check.sh:sh"
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

for pair in "${PAIRS[@]}"; do
  IFS=':' read -r REL_SRC REL_DEST STYLE <<< "$pair"
  SRC="${REPO_ROOT}/${REL_SRC}"
  DEST="${REPO_ROOT}/${REL_DEST}"

  INJECTED="$(inject_and_copy "$SRC" "$DEST" "$STYLE")"
  if [ "$(cat "$DEST" 2>/dev/null)" != "$INJECTED" ]; then
    printf '%s\n' "$INJECTED" > "$DEST"
    git add "$DEST"
    SYNCED=$((SYNCED + 1))
  fi
done

if [ "$SYNCED" -gt 0 ]; then
  echo "check-doctrine-sync: copied $SYNCED file(s) from root → .claude/skills/"
fi

exit 0
