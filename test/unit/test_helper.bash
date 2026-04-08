assert_output_matches() {
  local pattern="$1"
  if [[ ! "$output" =~ $pattern ]]; then
    echo "Expected output to match: $pattern" >&2
    echo "Actual output:" >&2
    printf '%s\n' "$output" >&2
    return 1
  fi
}

assert_output_not_matches() {
  local pattern="$1"
  if [[ "$output" =~ $pattern ]]; then
    echo "Did not expect output to match: $pattern" >&2
    echo "Actual output:" >&2
    printf '%s\n' "$output" >&2
    return 1
  fi
}

assert_dir_exists() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "Expected directory to exist: $path" >&2
    return 1
  fi
}

assert_file_exists() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "Expected file to exist: $path" >&2
    return 1
  fi
}
