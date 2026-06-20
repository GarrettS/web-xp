#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "AGENTS.md references the Editorial Gate" {
  grep -Fq '## Editorial Gate' "$REPO_ROOT/AGENTS.md"
  grep -Fq 'editorial-rules.md' "$REPO_ROOT/AGENTS.md"
}

@test "AGENTS.md links the gate rather than inlining it (Section Restatement)" {
  ! grep -Fq 'Three passes:' "$REPO_ROOT/AGENTS.md"
}
