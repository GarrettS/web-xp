#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$REPO_ROOT/bin/web-xp-on"
  BEGIN_MARKER='<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->'
  TMP_WORK="$(mktemp -d)"
  cd "$TMP_WORK"
}

teardown() {
  cd /
  rm -rf "$TMP_WORK"
}

@test "creates both contracts by default" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]

  assert_file_exists CLAUDE.md
  assert_file_exists CODEX.md
  [ "$(head -n 1 CLAUDE.md)" = "$BEGIN_MARKER" ]
  [ "$(head -n 1 CODEX.md)" = "$BEGIN_MARKER" ]
}

@test "prepends managed block and preserves existing content" {
  printf '# Local Notes\n\nKeep this content.\n' > CLAUDE.md

  run bash "$SCRIPT" claude
  [ "$status" -eq 0 ]

  [ "$(head -n 1 CLAUDE.md)" = "$BEGIN_MARKER" ]
  grep -Fq '# Local Notes' CLAUDE.md
  grep -Fq 'Keep this content.' CLAUDE.md
}

@test "replaces a drifted managed block and warns" {
  bash "$SCRIPT" codex
  perl -0pi -e 's/Read this file first on every task\./Read this file second on every task./' CODEX.md

  bash "$SCRIPT" codex 2>stderr.txt
  grep -Fq 'warning: replacing drifted Web XP managed block in CODEX.md' stderr.txt
  grep -Fq 'Read this file first on every task.' CODEX.md
}

@test "preview shows the proposed diff without writing" {
  run bash "$SCRIPT" --preview codex
  [ "$status" -eq 0 ]

  [ ! -f CODEX.md ]
  assert_output_matches '\+\+\+'
  assert_output_matches 'Read this file first on every task\.'
}
