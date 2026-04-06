#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  INSTALL_SCRIPT="$REPO_ROOT/bin/install.sh"
  TMP_HOME="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "installs all Claude skills" {
  run env HOME="$TMP_HOME" bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]

  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-check"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-review"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-apply"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-init"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-on"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-off"
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-remove"
}

@test "replaces stale Web XP files on reinstall" {
  # Pre-seed a stale standards file and a stale skill dir
  mkdir -p "$TMP_HOME/.claude/skills/web-xp-check"
  echo "stale" > "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md"
  echo "stale" > "$TMP_HOME/.claude/skills/code-guidelines.md"

  run env HOME="$TMP_HOME" bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]

  # Stale content should be replaced with real content
  [ "$(head -1 "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md")" != "stale" ]
  [ "$(head -1 "$TMP_HOME/.claude/skills/code-guidelines.md")" != "stale" ]
}

@test "preserves unrelated files in skills directory" {
  mkdir -p "$TMP_HOME/.claude/skills"
  echo "keep me" > "$TMP_HOME/.claude/skills/my-custom-skill.md"

  run env HOME="$TMP_HOME" bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]

  # Unrelated file should survive
  [ -f "$TMP_HOME/.claude/skills/my-custom-skill.md" ]
  [ "$(cat "$TMP_HOME/.claude/skills/my-custom-skill.md")" = "keep me" ]
}

@test "installs all Codex skills" {
  run env HOME="$TMP_HOME" bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]

  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-check"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-review"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-apply"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-init"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-on"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-off"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-remove"
}
