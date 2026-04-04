#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHARED_DIR="$REPO_ROOT/adapters/shared-base/skills"

yaml_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/''/g")"
}

shared_body() {
  local shared_file="$1"
  awk '
    /^## Purpose$/ { found = 1 }
    found {
      if ($0 == "## Adapter bindings") {
        skip = 1
        next
      }
      if (skip && /^## /) {
        skip = 0
      }
      if (!skip) {
        print
      }
    }
  ' "$shared_file"
}

shared_activation() {
  local shared_file="$1"

  awk '
    /^## Activation$/ { found = 1; next }
    found && /^## / { exit }
    found { print }
  ' "$shared_file" | sed '/^$/d' | paste -sd' ' -
}

build_claude_skill() {
  local name="$1"
  local bindings="$2"
  local shared_file="$SHARED_DIR/${name}.md"
  local output="$REPO_ROOT/adapters/claude/${name}/SKILL.md"
  local title
  local description_yaml

  title="$(sed -n '1s/^# //p' "$shared_file")"
  description_yaml="$(yaml_quote "$(shared_activation "$shared_file")")"
  mkdir -p "$(dirname "$output")"

  {
    cat <<EOF
---
name: ${name}
description: ${description_yaml}
---

# ${title}

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/${name}.md + Claude bindings. -->

## Claude bindings

${bindings}

## Shared capability

EOF
    shared_body "$shared_file"
  } > "$output"
}

build_codex_skill() {
  local name="$1"
  local bindings="$2"
  local shared_file="$SHARED_DIR/${name}.md"
  local output="$REPO_ROOT/adapters/codex/skills/${name}/SKILL.md"
  local title
  local description_yaml

  title="$(sed -n '1s/^# //p' "$shared_file")"
  description_yaml="$(yaml_quote "$(shared_activation "$shared_file")")"
  mkdir -p "$(dirname "$output")"

  {
    cat <<EOF
---
name: ${name}
description: ${description_yaml}
---

# ${title}

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/${name}.md + Codex bindings. -->

## Codex bindings

${bindings}

## Shared capability

EOF
    shared_body "$shared_file"
  } > "$output"
}

build_claude_skill "web-xp" \
  "- Read \`\${CLAUDE_SKILL_DIR}/../code-guidelines.md\`.
- Read \`\${CLAUDE_SKILL_DIR}/../code-philosophy.md\`.
- Treat \`/web-xp\` as the Claude capability surface."

build_claude_skill "web-xp-check" \
  "- Run \`bin/pre-commit-check.sh\` if it exists in the project; otherwise run \`bash \${CLAUDE_SKILL_DIR}/../pre-commit-check.sh\`.
- Refer users to \`/web-xp-review\` for arbitrary files outside git diff review.
- Use Claude slash-command names in user-facing examples."

build_claude_skill "web-xp-review" \
  "- Read \`\${CLAUDE_SKILL_DIR}/../code-guidelines.md\`.
- Read \`\${CLAUDE_SKILL_DIR}/../code-philosophy.md\`.
- Use Claude slash-command names when referencing related capabilities."

build_claude_skill "web-xp-apply" \
  "- If findings are missing, run \`/web-xp-check\` first.
- Make edits using Claude's normal editing tools.
- Run \`bin/pre-commit-check.sh\` if it exists in the project; otherwise run \`bash \${CLAUDE_SKILL_DIR}/../pre-commit-check.sh\` after approved edits."

build_claude_skill "web-xp-init" \
  "- Project contract file: \`CLAUDE.md\`.
- Missing install message: \`Install Web XP first: git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh\`
- Delegate to \`~/.web-xp/bin/web-xp-init claude\`.
- Claude does not require a preview-first flow in this build."

build_claude_skill "web-xp-on" \
  "- Project contract file: \`CLAUDE.md\`.
- Tell the user to run \`/web-xp-init\` if setup is missing.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_claude_skill "web-xp-off" \
  "- Project contract file: \`CLAUDE.md\`.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_claude_skill "web-xp-remove" \
  "- Project contract file: \`CLAUDE.md\`.
- Delegate to \`~/.web-xp/bin/web-xp-remove claude\`."

build_codex_skill "web-xp" \
  "- Read \`~/.web-xp/code-guidelines.md\`.
- Read \`~/.web-xp/code-philosophy.md\`.
- Treat \`web-xp\` as the Codex capability surface."

build_codex_skill "web-xp-check" \
  "- Run \`bash ~/.web-xp/bin/pre-commit-check.sh\`.
- Refer users to \`web-xp-review\` for arbitrary files outside git diff review.
- Use Codex capability names without slash prefixes."

build_codex_skill "web-xp-review" \
  "- Read \`~/.web-xp/code-guidelines.md\`.
- Read \`~/.web-xp/code-philosophy.md\`.
- Refer to related Codex capabilities without slash prefixes."

build_codex_skill "web-xp-apply" \
  "- If findings are missing, run \`web-xp-check\` first.
- Make edits using Codex's normal file editing tools.
- Run \`bash ~/.web-xp/bin/pre-commit-check.sh\` after approved edits."

build_codex_skill "web-xp-init" \
  "- Project contract file: \`CODEX.md\`.
- Missing install message: \`Install Web XP first: git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh\`
- Preview first with \`~/.web-xp/bin/web-xp-init --preview codex\`.
- Ask for confirmation before write.
- On approval, delegate to \`~/.web-xp/bin/web-xp-init codex\`."

build_codex_skill "web-xp-on" \
  "- Project contract file: \`CODEX.md\`.
- Tell the user to run \`web-xp-init\` if setup is missing.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_codex_skill "web-xp-off" \
  "- Project contract file: \`CODEX.md\`.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_codex_skill "web-xp-remove" \
  "- Project contract file: \`CODEX.md\`.
- Delegate to \`~/.web-xp/bin/web-xp-remove codex\`."
