#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCOPE="$REPO_ROOT/tools/review-scope.sh"
  DIFF="$REPO_ROOT/tools/review-diff.sh"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

# review-scope.sh's output for a path list, one path per line so tests can match.
scope_of() {
  printf '%s\0' "$@" | bash "$SCOPE" | tr '\0' '\n'
}

@test "review-scope keeps app code (.js .mjs .ts .html .css)" {
  out="$(scope_of src/app.js m.mjs t.ts page.html style.css)"
  for f in src/app.js m.mjs t.ts page.html style.css; do
    printf '%s\n' "$out" | grep -qxF "$f"
  done
}

@test "review-scope drops non-code files" {
  out="$(scope_of README.md data.json icon.svg Makefile)"
  [ -z "$out" ]
}

@test "review-scope excludes test code by directory" {
  out="$(scope_of test/a.js tests/b.js src/__tests__/c.js spec/d.js e2e/e.mjs)"
  [ -z "$out" ]
}

@test "review-scope excludes test code by file name" {
  out="$(scope_of a.test.js b.spec.mjs src/c.test.ts)"
  [ -z "$out" ]
}

@test "review-scope matches extensions case-insensitively" {
  out="$(scope_of App.JS Mod.MJS)"
  printf '%s\n' "$out" | grep -qxF "App.JS"
  printf '%s\n' "$out" | grep -qxF "Mod.MJS"
}

@test "review-diff includes app changes and excludes test and non-code files" {
  cd "$TMP"
  git init -q; git config user.email t@t; git config user.name t
  mkdir -p test e2e
  printf 'export const a = 1\n' > app.js
  printf 'export const t = 1\n' > test/base.js
  git add -A; git commit -qm init
  printf 'export const a = 2\n' > app.js        # tracked app change -> in
  printf 'export const t = 2\n' > test/base.js  # tracked test change -> out
  printf 'export const n = 1\n' > new.js         # untracked app -> in
  printf 'export const e = 1\n' > e2e/flow.mjs   # untracked test -> out
  printf 'notes\n' > notes.md                    # untracked non-code -> out
  run bash "$DIFF"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qF "app.js"
  echo "$output" | grep -qF "new.js"
  ! echo "$output" | grep -qF "test/base.js"
  ! echo "$output" | grep -qF "e2e/flow.mjs"
  ! echo "$output" | grep -qF "notes.md"
}

@test "review-diff hash is deterministic across runs" {
  cd "$TMP"
  git init -q; git config user.email t@t; git config user.name t
  printf 'export const a = 1\n' > app.js
  git add -A; git commit -qm init
  printf 'export const a = 2\n' > app.js
  printf 'export const n = 1\n' > new.js
  h1="$(bash "$DIFF" | git hash-object --no-filters --stdin)"
  h2="$(bash "$DIFF" | git hash-object --no-filters --stdin)"
  [ "$h1" = "$h2" ]
}
