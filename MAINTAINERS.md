# Web XP — Maintainers

For people working on the Web XP repo itself.

---

## Metadoctrine

Metadoctrine defines how Web XP doctrine is organized and consumed.

## What Is Web XP Doctrine?

Web XP *doctrine* is the principles, patterns, practices, and rules for authoring code maintained in Markdown for human and agent consumption.

For agents, Web XP doctrine values high-quality output, consistent cross-agent behavior, token efficiency, and adaptability to new agents. For humans, it values clarity, coherence, and maintainability.

Metadoctrine is shaped by how humans and agents read and process the doctrine. When cleanup work exposes a placement problem, clarify the metadoctrine. When the metadoctrine becomes clearer, update the doctrine to match it.

Doctrine Files:
- **Stated doctrine** (`code-guidelines.md`) states the rules for code.
- **Interpretive doctrine** (`code-philosophy.md`) explains how to understand and apply the doctrine.

## Enforcement
Agents enforce doctrine with:

  - Skills — instruct agents to read and apply doctrine
  - Agent contract files — persist always-on doctrine enforcement state for a project
  - Pre-commit check — mechanically enforce doctrine rules that can be checked automatically.

```text
  ┌────────────────────────────────────────────┐
  │           Web XP Doctrine Source           │
  │                                            │
  │  code-guidelines.md                        │
  │  code-philosophy.md                        │
  └────────────────────────────────────────────┘
                   │
     ┌─────────────┼─────────────┬──────────────┐
     │             │             │              │
   reads         activates      enforces       🍒
     │             │             │
     ▼             ▼             ▼
  ┌───────────┐ ┌───────────┐ ┌────────────┐
  │ Skills    │ │ Contracts │ │ Pre-commit │
  │           │ │           │ │            │
  │ tell      │ │ persist   │ │ checks     │
  │ agents to │ │ always-on │ │ doctrine   │
  │ apply     │ │ state     │ │ rules      │
  │ doctrine  │ │           │ │            │
  └───────────┘ └───────────┘ └────────────┘
```

## Doctrine Maintenance and Modification Decision Procedure:
1. Does this directly state what code should look like, what pattern is correct, or what counts as a violation? Put it in stated doctrine.
2. Does it explain why a rule exists, how to interpret it, or how to reason through ambiguity? Put it in interpretive doctrine.
3. Does it operationalize the doctrine in agent use?
   - loading, priming, or summaries -> skills
   - activation or enforcement-state behavior -> contracts
   - mechanical checks or enforcement -> `bin/pre-commit-check.sh` and similar tooling
4. Is it about packaging, build flow, maintainer workflow, or repo operation rather than the doctrine itself? Keep it in maintainer process / architecture.

Anti-bleed rules:
- Writing `because`, `the reason is`, or other extended justification in `code-guidelines.md` usually means the text is interpretive doctrine.
- Copy-pasting a binding rule into a skill or contract is duplicated operational doctrine. Reference the source unless a short runtime prompt that orients the agent without restating the rule is needed.
- If a check enforces something not stated in doctrine, the check is inventing doctrine.
- Comments do not define program behavior. If a program consumes something as authoritative input, it must not be encoded as a comment.

Propagation path:
- When stated doctrine changes, check interpretive and operational doctrine.
- When interpretive doctrine changes, check whether stated doctrine or operational summaries now need adjustment.
- When operational doctrine changes, check that it still matches and points back to stated and interpretive doctrine.
- When maintainer process changes, check whether it changes how doctrine work is classified or propagated.

Streamlining rule:
- Streamline by improving placement, sharpening rules, and reducing hot-path duplication and verbiage without weakening meaning.

Change risk:
- Treat doctrine edits as changes to a working instruction system, not just prose cleanup.
- Prefer in-place clarification over cross-document moves.
- Moving content between files changes adjacency, loading, and retention. Make that kind of change only when the expected behavioral gain is clear.

Requirement language:
- Plain English is the default.
- RFC 2119 keywords ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119.txt)) are used only for tight agent operations to ensure behavioral consistency. 

Change note:
- Every doctrine cleanup change should state whether the metadoctrine changed or held.
- Put that note in the main review artifact for the change: PR description if present, otherwise the issue comment or commit message.


## Adapters

Web XP's standard is agent-agnostic — one doctrine, enforced the same way regardless of which agent runs it. Adapters are the packaging that makes this work: each agent gets its own skill format, file layout, and install path, but they all implement the same skills from the same shared source. For the full architecture — roles, enforcement modes, adapter interface — see [`DESIGN.md`](DESIGN.md).

## Adapter packaging details

- **Claude Code**: generated skill directories in `adapters/claude/`, built from `adapters/shared-base/skills/` plus Claude bindings, synced to `.claude/skills/` for local development, copied to `~/.claude/skills/` on install. See `adapters/claude/README.md`.
- **Codex**: generated skill directories in `adapters/codex/skills/`, built from `adapters/shared-base/skills/` plus Codex bindings and copied to `$HOME/.agents/skills/` on install. See `adapters/codex/README.md`.

Built templates (`CLAUDE.example.md`, `CODEX.example.md`) are generated by `tools/build-contracts.sh` from `adapters/shared-base/AGENT.md` + per-agent overlays. Built skill/spec outputs are generated by `tools/build-adapter-skills.sh` from `adapters/shared-base/skills/` + per-adapter bindings. Do not put maintainer comments in the shared base contract, shared skill source, or overlays — they will appear verbatim in emitted artifacts. See `adapters/shared-base/README.md` for the shared source layout.

When shared skill behavior changes, rebuild and resync in this order:

1. `bash tools/build-adapter-skills.sh`
2. `bash tools/check-web-xp-sync.sh`

When shared contract behavior changes, also run:

1. `bash tools/build-contracts.sh`

## `install.sh`, `uninstall.sh`, and runtime inventory

`bin/install.sh` has two parallel jobs because Claude and Codex both use discovered skill folders.

- For Claude, install copies `adapters/claude/*` into `~/.claude/skills/`.
- For Codex, install copies `adapters/codex/skills/*` into `$HOME/.agents/skills/`.
- Install also writes a system-level manifest at `~/.web-xp/web-xp-manifest.txt` in normal use. The manifest is a flat file: one managed installed file path per line, plus an optional header comment.
- `bin/uninstall.sh` reads that manifest for exact removal. If the manifest is missing, uninstall falls back to the older glob-based cleanup path for backward compatibility with pre-manifest installs.

Why Codex is now packaged this way:

- Codex discovers user-level skills from `$HOME/.agents/skills/` ([official skills doc](https://developers.openai.com/codex/skills)).
- Clean-state probing on `codex-cli 0.118.0` confirmed explicit discovery works from this path for both bootstrap and non-bootstrap skills.
- Using discovered skill folders for both Claude and Codex keeps the adapter structure symmetric and removes the old Codex split model.
- Setup and cleanup still delegate to canonical shell commands (`bin/web-xp-on`, `bin/web-xp-off`), keeping project contract mutation logic in one place.

What `install.sh` does for Codex:

- copies every directory under `adapters/codex/skills/` into `$HOME/.agents/skills/`
- removes any previous copies first so the installed skill directory is replaced cleanly
- reconciles any previously recorded manifest entries that no longer belong to the current install

What stays in the Web XP install:

- the discovered runtime surface is the installed skill tree in `$HOME/.agents/skills/`
- the flat manifest in `~/.web-xp/web-xp-manifest.txt` is the system-level inventory for install/uninstall cleanup

If Codex later changes its documented user-level path, revisit this section and `bin/install.sh` together.

## Canonical project setup implementation

Project setup and cleanup are centralized in shell scripts:

- `bin/web-xp-on`
- `bin/web-xp-off`

Agent-specific setup skills should delegate to those scripts rather than reimplement the file mutation logic.

Why this is centralized:

- one canonical implementation for create vs prepend vs replace vs remove behavior
- cross-agent consistency for managed-block semantics
- a stable, testable entrypoint for project setup outside any single agent runtime
- smoother Codex setup under the external-install model, where a concrete installed command is better than manual template copying

System vs agent boundary:

- `bin/web-xp-on` and `bin/web-xp-off` default to `all` (both adapters) when called directly from the command line. This is correct for direct CLI use, but agent skills must pass the specific agent type (`claude` or `codex`) so a skill only touches its own project contract.
- Agent skills pass the specific agent type (`claude` or `codex`), so each skill only touches its own contract file. A skill invoked by one agent must not modify the other agent's project state.
- `bin/install.sh` and `bin/uninstall.sh` are also system-level — they manage the machine-wide install surface across all adapters.

What this means in practice:

- setup skills are thin wrappers over the canonical shell implementation
- skills pass the agent type to stay within their boundary; shell scripts default to `all` for direct CLI use
- regression coverage belongs around the shell commands because that is where the contract mutation semantics live
- README only needs the user-facing commands and outcomes; the architectural rationale lives here

## Building a new adapter

To add Web XP support for another agent platform:

1. Implement the four runtime capabilities and two setup capabilities defined in `DESIGN.md`.
2. Point all file references at the core files (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`).
3. Define a project contract mechanism that can express `off | explicit | always-on`.
4. Place adapter documentation and authored packaging source in `adapters/<platform>/`. If the platform requires a specific path for skill discovery (e.g. `.claude/skills/` for Claude Code), generate or sync that runtime/package path from the adapter source and document it in the adapter README.

The adapter does not need to implement orchestration. That is a separate layer.

## Testing

```bash
brew install bats-core    # one-time
bash test/run-unit.sh     # run all unit tests
```

Unit tests (Bats) cover install, pre-commit checks, and adapter skill generation. E2E tests require a separate macOS user for clean-state isolation due to cross-project session state leaking ([#21](https://github.com/GarrettS/web-xp/issues/21)).

See [`test/README.md`](test/README.md) for the full test suite reference, e2e setup, fixtures, and known limitations.

## Maintainer Workflow

Cross-agent maintainer coordination is documented in `internal/AGENT-HANDOFF.md`.

- The protocol belongs in the repo because it is part of how maintainers work on Web XP itself.
- The live inbox/outbox message files do not belong in the repo.
- Keep the protocol document in-repo, but keep the live handoff state in a maintainer-local path outside the checkout.
- In this repo's own contracts, the live handoff path is `/tmp/web-xp-agent-handoff/`.

## Repo structure

Core Web XP lives at the repo root. Shared authored contract and skill source live under `adapters/shared-base/`. Concrete adapter packaging lives under `adapters/<platform>/`. Some adapters also have platform-native runtime/package paths generated from that packaging (e.g. `.claude/skills/` for Claude Code).

```
web-xp/
├── code-guidelines.md          # core standard
├── code-philosophy.md          # core explanatory context
├── bin/
│   ├── pre-commit-check.sh     # core mechanical checks
│   ├── install.sh              # post-clone / post-pull installer + manifest writer
│   ├── web-xp-on              # canonical project setup
│   ├── web-xp-off             # project cleanup command
│   └── web-xp-off              # canonical project cleanup
├── tools/
│   ├── build-contracts.sh      # builds agent contracts from shared base + overlays
│   ├── build-adapter-skills.sh # builds concrete skill/spec packaging from shared skill source
│   └── check-web-xp-sync.sh    # internal sync (this repo only)
├── adapters/
│   ├── shared-base/            # adapter-neutral contract and skill source
│   │   ├── AGENT.md
│   │   ├── README.md
│   │   └── skills/
│   ├── claude/                 # Claude overlay, built contract, built skills, docs
│   │   ├── web-xp/
│   │   ├── web-xp-check/
│   │   ├── web-xp-review/
│   │   ├── web-xp-on/
│   │   └── web-xp-off/
│   └── codex/                  # Codex overlay, built contract, built skill files, docs
│       └── skills/             # Codex skills (installed to $HOME/.agents/skills/)
│           ├── web-xp/
│           ├── web-xp-check/
│           ├── web-xp-review/
│           ├── web-xp-on/
│           └── web-xp-off/
├── .claude/
│   └── skills/                 # generated Claude runtime/package path
│       ├── web-xp/
│       ├── web-xp-check/
│       ├── web-xp-review/
│       ├── web-xp-on/
│       └── web-xp-off/
├── internal/                   # maintainer-only workflow docs and notes
│   ├── AGENT-HANDOFF.md
│   ├── DEV-WORKFLOW-INTEGRATION.md
│   ├── node-pilot-manifest-issue-draft.md
├── test/
│   ├── unit/                   # Bats unit tests
│   │   ├── pre-commit.bats
│   │   ├── sync.bats
│   │   ├── install.bats
│   │   └── test_helper.bash
│   ├── badcode-test-website/   # test fixtures + protocols
│   │   ├── index.html
│   │   ├── app.js
│   │   ├── TEST-PROTOCOL.md
│   │   ├── MANUAL-TEST.md
│   │   └── TEST-RESULTS.md
│   ├── run-unit.sh             # Bats test runner
│   ├── test-pre-commit.sh      # legacy (being replaced by Bats)
│   ├── test-sync.sh            # legacy (being replaced by Bats)
│   └── test-install.sh         # legacy (being replaced by Bats)
├── CLAUDE.md                   # this repo's own contract
├── CODEX.md                    # this repo's own contract
├── MAINTAINERS.md              # this file
└── README.md                   # public docs
```

## Build order

1. ~~**Formalize enforcement modes**~~ — done.
2. ~~**Add adapter scaffolding**~~ — done.
3. ~~**Build second adapter (Codex)**~~ — done. Tested against elitefuellabs.com.
4. ~~**Rewrite public docs**~~ — done. README is agent-neutral.
5. **Design orchestration as a separate layer** — outside current Web XP core scope.
6. **Continuous audit mode** — timer-driven auditor topology using orchestration or equivalent tooling.

Steps 1-4 complete. Later orchestration work is separate from the current install/contract model.
