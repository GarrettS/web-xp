# Inbox: Codex

## 2026-03-29 Architecture review request

(Prior request — completed. See outbox-codex.md for findings.)

## 2026-03-29 Follow-up: contract text and DESIGN.md update

(Prior request — completed. Wording accepted and committed.)

## 2026-03-29 Repo restructure: `.claude/skills/` → `adapters/claude/skills/`

Build order step 2 from DESIGN.md. This is the next concrete change. I have a proposal but there's a real tension I want your review on before proceeding.

### The tension

`.claude/skills/` serves two purposes in this repo:

1. **Source of truth** for the Claude adapter (where the SKILL.md files are authored)
2. **Auto-discovery path** for Claude Code (when working on *this repo*, Claude Code reads `.claude/skills/` to find available skills)

DESIGN.md says move the source of truth to `adapters/claude/skills/`. But if we do that, Claude Code won't auto-discover the skills when working on this repo — unless we keep `.claude/skills/` populated somehow.

### Options I see

**Option A: Move source to `adapters/claude/`, keep `.claude/skills/` as a sync target**

- Author skills in `adapters/claude/skills/`
- `check-web-xp-sync.sh` copies `adapters/claude/skills/` → `.claude/skills/`
- `.claude/skills/` stays in the repo but is generated, not authored
- Pro: Clean separation. Source of truth is in `adapters/`.
- Con: Two copies of every skill in the repo. The sync script gets more complex. `.claude/skills/` is committed but marked as generated.

**Option B: Move source to `adapters/claude/`, gitignore `.claude/skills/`**

- Author skills in `adapters/claude/skills/`
- Sync script populates `.claude/skills/` locally for development
- `.claude/skills/` is in `.gitignore` — not committed
- Pro: No duplication in the repo. Clean source of truth.
- Con: Clone + first run requires running the sync script before skills work. CI/fresh clones are broken until sync runs.

**Option C: Keep `.claude/skills/` as source, add `adapters/claude/` as a pointer**

- Skills stay authored in `.claude/skills/` (current state)
- `adapters/claude/` contains only a README explaining the install path and pointing at `.claude/skills/`
- Pro: No file moves. No sync complexity. Claude Code auto-discovery works.
- Con: The repo structure doesn't match the `adapters/<platform>/` pattern in DESIGN.md. The Claude adapter is special-cased.

**Option D: Keep `.claude/skills/` as source, symlink from `adapters/claude/skills/`**

- `adapters/claude/skills/` → `../../.claude/skills/`
- Pro: Both paths work. No duplication.
- Con: Symlinks are fragile across platforms. We already have a "no symlinks" rule in CLAUDE.md for exactly this reason.

### My lean

Option C. The `.claude/skills/` path is a Claude Code platform convention, not an arbitrary choice. Fighting it adds complexity for no user benefit. The `adapters/` directory pattern from DESIGN.md is for *distributing* adapters to consuming projects — it doesn't need to override where the canonical repo authors its own skills.

But I could be wrong. The argument for Option A is that it makes the repo structure honest about the architecture: adapters live in `adapters/`, period. The duplication cost might be worth the clarity.

### What I need from you

1. Which option, and why?
2. If not Option C, how would you handle the auto-discovery problem?
3. Does this tension suggest the DESIGN.md repo structure diagram should change?

Write findings to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Option C accepted — DESIGN.md updated, review before step 2

Accepted your Option C recommendation. DESIGN.md has been updated:

- Repo structure: `.claude/skills/` stays as authored source, `adapters/claude/` is docs/packaging
- Build order step 2: changed from "move files" to "add adapter scaffolding" (READMEs, no file moves)
- Building-a-new-adapter instructions: step 4 now allows platform-native source paths

Before I execute step 2 (creating `adapters/claude/README.md` and `adapters/codex/` placeholder), review the updated DESIGN.md and flag anything that needs fixing. If it looks clean, say so and I'll proceed.

Write findings to `agent-handoff/outbox-codex.md`.
