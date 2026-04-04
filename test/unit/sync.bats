#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SYNC_SCRIPT="$REPO_ROOT/tools/check-web-xp-sync.sh"
  BUILD_SCRIPT="$REPO_ROOT/tools/build-adapter-skills.sh"
  CASE_DIR="$(mktemp -d)"
  git -C "$CASE_DIR" init -q
  mkdir -p "$CASE_DIR/tools"
  cp "$SYNC_SCRIPT" "$CASE_DIR/tools/check-web-xp-sync.sh"
  cp "$BUILD_SCRIPT" "$CASE_DIR/tools/build-adapter-skills.sh"
  write_file "code-guidelines.md" "# Guidelines"
  write_file "code-philosophy.md" "# Philosophy"
  write_file "bin/pre-commit-check.sh" '#!/usr/bin/env bash
echo ok'

  for skill_name in web-xp web-xp-check web-xp-review web-xp-apply web-xp-init web-xp-on web-xp-off web-xp-remove; do
    write_file "adapters/shared-base/skills/${skill_name}.md" "# ${skill_name}

## Activation

Activate when explicitly invoked by name.

## Purpose

Body for ${skill_name}"
  done

  run bash -lc "cd \"$CASE_DIR\" && bash tools/check-web-xp-sync.sh >/dev/null"
  [ "$status" -eq 0 ]
  TARGET="$CASE_DIR/.claude/skills/web-xp/SKILL.md"
}

teardown() {
  rm -rf "$CASE_DIR"
}

write_file() {
  local relpath="$1"
  local content="$2"
  mkdir -p "$(dirname "$CASE_DIR/$relpath")"
  printf '%s\n' "$content" > "$CASE_DIR/$relpath"
}

@test "generated skill keeps YAML frontmatter first" {
  first_line="$(head -1 "$TARGET")"
  [ "$first_line" = "---" ]
}

@test "do not edit header comes after frontmatter" {
  run awk 'BEGIN{delim=0; header=0} {if ($0 == "---") delim++; if (index($0, "DO NOT EDIT") > 0 && delim == 2) header=1} END{exit header ? 0 : 1}' "$TARGET"
  [ "$status" -eq 0 ]
}

@test "do not edit header is not before frontmatter" {
  run awk 'BEGIN{delim=0; bad=0} {if (index($0, "DO NOT EDIT") > 0 && delim < 2) bad=1; if ($0 == "---") delim++} END{exit bad ? 0 : 1}' "$TARGET"
  [ "$status" -eq 1 ]
}
