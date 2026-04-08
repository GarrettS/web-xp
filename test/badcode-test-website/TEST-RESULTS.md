# Web XP Codex Migration Test Results

Last updated: 2026-04-04

This file records the observed results for the Codex native-skill migration.
It is separate from `TEST-PROTOCOL.md`, which defines the procedure.

## Environment

- Repo: `web-xp`
- Codex CLI: `0.118.0`
- Codex user skill path: `$HOME/.agents/skills`

## Result Summary

### Verified locally in this repo

1. **Generated skill packaging**
- `tools/build-adapter-skills.sh` rebuilt the Claude and Codex skill artifacts successfully.
- Generated `SKILL.md` files use YAML-safe frontmatter.

2. **Contract generation**
- `tools/build-contracts.sh` rebuilt `adapters/codex/CODEX.example.md`.
- The built Codex contract does not reference the old flat spec-directory path.

3. **Install behavior**
- `bin/install.sh` installs all Codex skills into `$HOME/.agents/skills`.

4. **Unit test conversion**
- `bats-core` installed successfully.
- `bash test/run-unit.sh` passed all 18 tests.

### Reported in agent handoff and treated as manual verification

Source: latest `/tmp/web-xp-agent-handoff/claude-to-codex.md` entries from 2026-04-04.

1. **E2E skill discovery**
- `codex exec --full-auto "run web-xp-check on this project"` discovered `web-xp-check` from `$HOME/.agents/skills/web-xp-check/SKILL.md`.

2. **E2E skill execution**
- Codex loaded the skill and ran `pre-commit-check.sh`.
- Codex reported 11 violations.
- Codex stopped before structural review because mechanical checks failed first.

3. **Manual behavior regressions discovered**
- `#17`: session-skill descriptions auto-activate without project contract
- `#18`: always-on enforcement widened scope and refactored unrelated code
- `#19`: `web-xp-check` ran against the whole codebase when no diff existed

## Current Status

- Codex native skill discovery from `$HOME/.agents/skills` is validated.
- Flat-file Codex skill artifacts are no longer part of the active runtime model.
- Unit-test coverage is now available under `test/unit/*.bats`.
- E2E coverage remains primarily manual and protocol-driven; see issue `#20` for longer-term strategy work.
