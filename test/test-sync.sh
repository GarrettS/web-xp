#!/bin/bash
# Regression tests for tools/check-web-xp-sync.sh
# Runs the sync in an isolated temp git repo.
#
# Usage: bash test/test-sync.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/tools/check-web-xp-sync.sh"

PASS_COUNT=0
FAIL_COUNT=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

CASE_DIR="$(mktemp -d)"
trap 'rm -rf "$CASE_DIR"' EXIT

assert_true() {
  local name="$1"
  local cmd="$2"

  if eval "$cmd"; then
    echo -e "${GREEN}PASS${NC}  $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "${RED}FAIL${NC}  $name"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

write_file() {
  local relpath="$1"
  local content="$2"
  mkdir -p "$(dirname "$CASE_DIR/$relpath")"
  printf '%s\n' "$content" > "$CASE_DIR/$relpath"
}

echo "=== Sync Regression Tests ==="
echo ""

git -C "$CASE_DIR" init -q

write_file "code-guidelines.md" "# Guidelines"
write_file "code-philosophy.md" "# Philosophy"
write_file "bin/pre-commit-check.sh" '#!/usr/bin/env bash
echo ok'
mkdir -p "$CASE_DIR/tools"
cp "$SYNC_SCRIPT" "$CASE_DIR/tools/check-web-xp-sync.sh"

for skill_name in web-xp web-xp-check web-xp-review web-xp-apply web-xp-init web-xp-on web-xp-off; do
  write_file "adapters/claude/${skill_name}/SKILL.md" "---
name: ${skill_name}
description: test
---

Body for ${skill_name}"
done

(cd "$CASE_DIR" && bash tools/check-web-xp-sync.sh >/dev/null)

TARGET="$CASE_DIR/.claude/skills/web-xp/SKILL.md"

assert_true "Generated skill keeps YAML frontmatter first" \
  "[ \"$(head -1 "$TARGET")\" = '---' ]"

assert_true "DO NOT EDIT header comes after frontmatter" \
  "awk 'BEGIN{delim=0; header=0} {if (\$0 == \"---\") delim++; if (index(\$0, \"DO NOT EDIT\") > 0 && delim == 2) header=1} END{exit header ? 0 : 1}' \"$TARGET\""

assert_true "DO NOT EDIT header is not before frontmatter" \
  "! awk 'BEGIN{delim=0; bad=0} {if (index(\$0, \"DO NOT EDIT\") > 0 && delim < 2) bad=1; if (\$0 == \"---\") delim++} END{exit bad ? 0 : 1}' \"$TARGET\""

echo ""
echo "=== Results: $PASS_COUNT passed, $FAIL_COUNT failed ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
