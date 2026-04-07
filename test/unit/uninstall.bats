#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  TMP_HOME="$(mktemp -d)"
  TMP_INSTALL="$TMP_HOME/.web-xp"

  mkdir -p "$TMP_INSTALL/bin" \
           "$TMP_HOME/.claude/skills/web-xp-check" \
           "$TMP_HOME/.agents/skills/web-xp-check"

  cp "$REPO_ROOT/bin/uninstall.sh" "$TMP_INSTALL/bin/uninstall.sh"
  echo "skill" > "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md"
  echo "skill" > "$TMP_HOME/.agents/skills/web-xp-check/SKILL.md"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "uninstall cancels by default" {
  run bash -lc "printf '\n' | HOME=\"$TMP_HOME\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]
  assert_output_matches "Uninstall cancelled\\."
  [ -d "$TMP_INSTALL" ]
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-check"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-check"
}

@test "uninstall removes installed skills and install root after confirmation" {
  run bash -lc "printf 'y\n' | HOME=\"$TMP_HOME\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]
  assert_output_matches "Web XP was removed from this machine\\."
  assert_output_matches "Project agent files \\(CLAUDE\\.md, CODEX\\.md\\) are not removed\\."
  [ ! -e "$TMP_INSTALL" ]
  [ ! -e "$TMP_HOME/.claude/skills/web-xp-check" ]
  [ ! -e "$TMP_HOME/.agents/skills/web-xp-check" ]
}
