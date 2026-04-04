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

build_claude_skill() {
  local name="$1"
  local description="$2"
  local bindings="$3"
  local shared_file="$SHARED_DIR/${name}.md"
  local output="$REPO_ROOT/adapters/claude/${name}/SKILL.md"
  local title
  local description_yaml

  title="$(sed -n '1s/^# //p' "$shared_file")"
  description_yaml="$(yaml_quote "$description")"
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
  local description="$2"
  local bindings="$3"
  local shared_file="$SHARED_DIR/${name}.md"
  local output="$REPO_ROOT/adapters/codex/skills/${name}/SKILL.md"
  local title
  local description_yaml

  title="$(sed -n '1s/^# //p' "$shared_file")"
  description_yaml="$(yaml_quote "$description")"
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
  "Load code-guidelines.md and code-philosophy.md as session constraints. Activate when: coding task begins, 'web-xp', 'web xp', 'code guidelines', 'standards', writing or reviewing JS/HTML/CSS." \
  "- Read \`\${CLAUDE_SKILL_DIR}/../code-guidelines.md\`.
- Read \`\${CLAUDE_SKILL_DIR}/../code-philosophy.md\`.
- Treat \`/web-xp\` as the Claude capability surface."

build_claude_skill "web-xp-check" \
  "Audit git diff against Web XP standard patterns. Activate when: about to commit, 'check my code', 'audit', 'pre-commit', 'review the diff', verifying quality." \
  "- Run \`bin/pre-commit-check.sh\` if it exists in the project; otherwise run \`bash \${CLAUDE_SKILL_DIR}/../pre-commit-check.sh\`.
- Refer users to \`/web-xp-review\` for arbitrary files outside git diff review.
- Use Claude slash-command names in user-facing examples."

build_claude_skill "web-xp-review" \
  "Review code against Web XP standards. Activate when: code pasted or file given, 'review this', 'what's wrong with this', evaluate quality, vanilla equivalent." \
  "- Read \`\${CLAUDE_SKILL_DIR}/../code-guidelines.md\`.
- Read \`\${CLAUDE_SKILL_DIR}/../code-philosophy.md\`.
- Use Claude slash-command names when referencing related capabilities."

build_claude_skill "web-xp-apply" \
  "Fix Web XP violations interactively with approval. Activate when: 'fix these', 'apply suggestions', 'refactor against standards', 'walk me through fixes'." \
  "- If findings are missing, run \`/web-xp-check\` first.
- Make edits using Claude's normal editing tools.
- Run \`bin/pre-commit-check.sh\` if it exists in the project; otherwise run \`bash \${CLAUDE_SKILL_DIR}/../pre-commit-check.sh\` after approved edits."

build_claude_skill "web-xp-init" \
  "Set up or update a project with Web XP standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'update CLAUDE.md', 'add pre-commit', 'init web-xp'." \
  "- Project contract file: \`CLAUDE.md\`.
- Missing install message: \`Install Web XP first: git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh\`
- Delegate to \`~/.web-xp/bin/web-xp-init claude\`.
- Claude does not require a preview-first flow in this build."

build_claude_skill "web-xp-on" \
  "Enable Web XP enforcement in CLAUDE.md. Activate when: 'turn on web-xp', 'enable standards', 'activate enforcement', 'web-xp on', 're-enable'." \
  "- Project contract file: \`CLAUDE.md\`.
- Tell the user to run \`/web-xp-init\` if setup is missing.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_claude_skill "web-xp-off" \
  "Disable Web XP enforcement in CLAUDE.md. Activate when: 'turn off web-xp', 'disable standards', 'pause enforcement', 'web-xp off', 'skip web-xp'." \
  "- Project contract file: \`CLAUDE.md\`.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_claude_skill "web-xp-remove" \
  "Remove Web XP from this Claude project by deleting the managed block from CLAUDE.md or removing the file if it only contains Web XP. Trigger: 'remove web-xp', 'uninstall from project', 'clean up CLAUDE.md', 'web-xp remove'." \
  "- Project contract file: \`CLAUDE.md\`.
- Delegate to \`~/.web-xp/bin/web-xp-remove claude\`."

build_codex_skill "web-xp" \
  "Load code-guidelines.md and code-philosophy.md as session constraints. Activate when: coding task begins, 'web-xp', 'web xp', 'code guidelines', 'standards', writing or reviewing JS/HTML/CSS." \
  "- Read \`~/.web-xp/code-guidelines.md\`.
- Read \`~/.web-xp/code-philosophy.md\`.
- Treat \`web-xp\` as the Codex capability surface."

build_codex_skill "web-xp-check" \
  "Audit git diff against Web XP standard patterns. Activate when: about to commit, 'check my code', 'audit', 'pre-commit', 'review the diff', verifying quality." \
  "- Run \`bash ~/.web-xp/bin/pre-commit-check.sh\`.
- Refer users to \`web-xp-review\` for arbitrary files outside git diff review.
- Use Codex capability names without slash prefixes."

build_codex_skill "web-xp-review" \
  "Review code against Web XP standards. Activate when: code pasted or file given, 'review this', 'what's wrong with this', evaluate quality, vanilla equivalent." \
  "- Read \`~/.web-xp/code-guidelines.md\`.
- Read \`~/.web-xp/code-philosophy.md\`.
- Refer to related Codex capabilities without slash prefixes."

build_codex_skill "web-xp-apply" \
  "Fix Web XP violations interactively with approval. Activate when: 'fix these', 'apply suggestions', 'refactor against standards', 'walk me through fixes'." \
  "- If findings are missing, run \`web-xp-check\` first.
- Make edits using Codex's normal file editing tools.
- Run \`bash ~/.web-xp/bin/pre-commit-check.sh\` after approved edits."

build_codex_skill "web-xp-init" \
  "Create or update a project's CODEX.md contract for Web XP. Trigger when the user says \"web-xp-init\", asks to initialize Web XP in a Codex project, create CODEX.md, or update the Web XP project contract." \
  "- Project contract file: \`CODEX.md\`.
- Missing install message: \`Install Web XP first: git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh\`
- Preview first with \`~/.web-xp/bin/web-xp-init --preview codex\`.
- Ask for confirmation before write.
- On approval, delegate to \`~/.web-xp/bin/web-xp-init codex\`."

build_codex_skill "web-xp-on" \
  "Enable Web XP enforcement in CODEX.md. Activate when: 'turn on web-xp', 'enable standards', 'activate enforcement', 'web-xp on', 're-enable'." \
  "- Project contract file: \`CODEX.md\`.
- Tell the user to run \`web-xp-init\` if setup is missing.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_codex_skill "web-xp-off" \
  "Disable Web XP enforcement in CODEX.md. Activate when: 'turn off web-xp', 'disable standards', 'pause enforcement', 'web-xp off', 'skip web-xp'." \
  "- Project contract file: \`CODEX.md\`.
- Recognize Web XP directives by the \`On every session\` and \`Before every commit\` sections in the managed block."

build_codex_skill "web-xp-remove" \
  "Remove Web XP from the current Codex project by deleting the managed block from CODEX.md or removing the file if it only contains Web XP. Trigger when the user says \"web-xp-remove\", asks to remove Web XP from a project, uninstall Web XP from the local project, or clean up CODEX.md." \
  "- Project contract file: \`CODEX.md\`.
- Delegate to \`~/.web-xp/bin/web-xp-remove codex\`."
