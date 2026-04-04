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
