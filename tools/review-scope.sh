#!/usr/bin/env bash
#
# review-scope.sh — decide which files the review looks at.
#
# Reads a NUL-delimited list of paths on stdin and writes, NUL-delimited to
# stdout, just the ones in scope. One place makes this decision so the change-set
# builder (review-diff.sh), the Stop hook's gate (review-stop-hook.sh), and the
# loop's touched-file list (review-loop.sh) can never disagree about scope.
#
# In scope: app code — files ending .js .mjs .ts .html .css.
#
# Out of scope: test code. It gets a separate review approach, so this loop does
# not judge it. A path is test code when it has a test directory anywhere in it
# (test*/, __tests__/, spec/, e2e/) or its file name is *.test.* or *.spec.* .
# Note: "test*/" also matches a directory like testimonials/; tighten this to
# test/ and tests/ if a project has app directories whose names start with
# "test".
#
set -uo pipefail
shopt -s nocasematch

while IFS= read -r -d '' f; do
  # App-code extension, or drop it.
  case "$f" in
    *.js|*.mjs|*.ts|*.html|*.css) ;;
    *) continue ;;
  esac
  # A test directory anywhere in the path. Lead with "/" so a top-level test
  # directory ("test/foo.js") matches the "*/dir/*" shapes too.
  case "/$f" in
    */test*/*|*/__tests__/*|*/spec/*|*/e2e/*) continue ;;
  esac
  # A test file name.
  case "$f" in
    *.test.*|*.spec.*) continue ;;
  esac
  printf '%s\0' "$f"
done
