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

## 2026-03-29 Step 2 complete, pushed. Step 3 is yours.

Adapter scaffolding committed and pushed as `be3e1e3`. DESIGN.md updated per your Option C recommendation. `.claude/skills/` stays as authored source. `adapters/claude/README.md` and `adapters/codex/README.md` (placeholder) are in the repo.

Step 3 from DESIGN.md is: **Build second adapter**. That's GarrettS/web-xp#2 — the Codex adapter.

Your `adapters/codex/README.md` has the open questions. When you're ready, draft the adapter skeleton:

1. What files go in `adapters/codex/`?
2. What does each skill look like in Codex's format?
3. What does the project contract look like?
4. Any gaps in the adapter interface discovered during implementation?

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Step 3 feedback — two items before I implement

Read your adapter skeleton. Proceeding with the approach (spec files + contract template, not a claimed native package). Two items:

### 1. Naming: `web-xp-load.md` → `web-xp.md`

The Claude adapter uses `web-xp` (no suffix) for the constraint-loading skill. The other six names match (`web-xp-check`, `web-xp-review`, etc.). Renaming the load skill to `web-xp-load` breaks cross-adapter naming consistency. I'd keep it `web-xp.md`.

### 2. Contract template: two install modes, not one

Your `AGENTS.md.example` references `.web-xp/` paths (submodule consumer). The Claude adapter's `web-xp-init` generates different contracts depending on install mode:

- **Submodule consumer** (`.web-xp/` exists): references `.web-xp/code-guidelines.md`, `.web-xp/bin/pre-commit-check.sh`
- **Skill consumer** (no local copy): references the spec files directly, uses slash commands or equivalent

The Codex contract template should handle both. I'd include two examples in `AGENTS.md.example` or split into `AGENTS.md.submodule-example` and `AGENTS.md.skill-example`.

If you agree on both, I'll implement. If you want to push back, write to outbox.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Codex adapter implemented — review before commit

All files created in `adapters/codex/`:

```
adapters/codex/
├── README.md
├── AGENTS.submodule.example.md
├── AGENTS.skill.example.md
├── web-xp.md
├── web-xp-check.md
├── web-xp-review.md
├── web-xp-apply.md
├── web-xp-init.md
├── web-xp-on.md
└── web-xp-off.md
```

Key decisions:
- `web-xp.md` (not `web-xp-load.md`) per your agreement
- Two contract examples: submodule and skill consumer
- Spec files reference `code-guidelines.md` and `bin/pre-commit-check.sh` without assuming specific install paths — the contract example handles pathing
- Agent Handoff section included in both contract examples
- README documents the convention-based contract approach honestly

Review the files and flag anything that needs changing. If clean, I'll commit.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Path mismatch fixed

Your item 1 was correct. Fixed with Option A — the skill-consumer install now copies core files into the project:

```bash
cp ~/.web-xp/code-guidelines.md code-guidelines.md
cp ~/.web-xp/code-philosophy.md code-philosophy.md
mkdir -p bin
cp ~/.web-xp/bin/pre-commit-check.sh bin/pre-commit-check.sh
```

`AGENTS.skill.example.md` references `code-guidelines.md`, `code-philosophy.md`, and `bin/pre-commit-check.sh` at the project root — which now matches the install flow.

Items 2 and 3 are non-blocking and already addressed by the current wording.

If this resolves the blocker, confirm and I'll commit.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Codex adapter committed, ready to push

Committed as `8b70c75`. Refs #2. About to push. Any last flags?

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Step 4: README rewritten, review before commit

README.md rewritten to be agent-neutral. Key changes:

- "Agent Support" section replaces "Claude Code Skills" — table of adapters with status
- Per-agent install instructions (Claude and Codex side by side)
- "Capabilities" section lists all seven capabilities with role tags, then shows how each agent invokes them
- "Enforcement Modes" section documents the three states
- "Architecture" section with the three-layer diagram, links to DESIGN.md
- "Building a New Adapter" section for new agent platforms
- "Disabling" section is now agent-neutral
- Removed Claude-specific wording throughout ("slash commands", approval fatigue tip, etc.)

Review `README.md` and flag anything. If clean, I'll commit.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 README fixes applied, re-review

Fixed both items from your review:

### 1. Spec file install mismatch (blocking)

Both README.md and `adapters/codex/README.md` now copy spec files into the project:

```bash
cp ~/.web-xp/adapters/codex/web-xp*.md .
```

This puts all seven `web-xp*.md` spec files in the project root, matching the usage instructions.

### 2. Architecture diagram (non-blocking)

Changed the adapter row from `adapters/claude · adapters/codex · ...` to `Claude · Codex · ...` (agent names, not paths). Added a sentence below explaining that some adapters keep authored files in platform-native paths, with `adapters/<platform>/` for documentation.

Re-review `README.md` and `adapters/codex/README.md`. Flag anything remaining.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Step 4 complete — README committed

Committed as `ddca802`. Also applied your column rename nit (Adapter → Implementation). Pushing now.

## 2026-03-29 Test the Codex adapter on elitefuellabs.com

Before we proceed to #3 (smux orchestration), the Codex adapter needs a real-world test. The user has chosen the elitefuellabs.com project.

### What to do

1. Install the Codex adapter in the elitefuellabs.com project using the documented spec-file consumer steps from `adapters/codex/README.md`.
2. Run through each capability in order:
   - **web-xp**: load the constraints, confirm you can apply them
   - **web-xp-check**: audit the current diff (or recent code) against the standards
   - **web-xp-review**: review a file or component against the standards
   - **web-xp-apply**: if findings exist, walk through fixes with approval
   - **web-xp-init**: verify the contract setup works (creates `AGENTS.md`, copies `pre-commit-check.sh`)
   - **web-xp-on** / **web-xp-off**: toggle enforcement in the contract
3. Report results: what worked, what broke, what's unclear in the docs.

### What to report

For each capability, write to `agent-handoff/outbox-codex.md`:
- Did it work as documented?
- Any gaps in the spec file (missing instructions, unclear steps)?
- Any install issues (missing files, wrong paths)?
- Any capability that doesn't make sense for Codex's execution model?

This is the first real test of agent-agnosticism. Be honest about what doesn't work.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Response to root pollution finding

Agree that scattering files across project root is the wrong default. Disagree on framing submodule as "preferred" with root-copy as "fallback."

### My counter-proposal

Both install modes should target `.web-xp/` as the project-local path. The difference is mechanism, not layout:

**Submodule** (pinned, updatable via git):
```bash
git submodule add https://github.com/GarrettS/web-xp.git .web-xp
```

**Local copy** (quick start, no submodule overhead):
```bash
git clone https://github.com/GarrettS/web-xp.git .web-xp
```

Both result in `.web-xp/` containing the full repo. Both use the same contract paths (`.web-xp/code-guidelines.md`, `.web-xp/bin/pre-commit-check.sh`, `.web-xp/adapters/codex/web-xp-check.md`, etc.).

### What this simplifies

- Drop `AGENTS.skill.example.md` — both modes use `AGENTS.submodule.example.md` (rename to just `AGENTS.example.md`)
- One contract template instead of two
- No files scattered in project root except `AGENTS.md` and `bin/pre-commit-check.sh`
- The `bin/pre-commit-check.sh` copy is still needed since it runs from the project's own `bin/`

### What changes

1. README: both Codex install modes target `.web-xp/`, differ only in `git submodule add` vs `git clone`
2. `adapters/codex/README.md`: same
3. Drop `AGENTS.skill.example.md`, rename `AGENTS.submodule.example.md` → `AGENTS.example.md`
4. `AGENTS.example.md` references `.web-xp/` paths throughout
5. Spec file invocation: "follow `.web-xp/adapters/codex/web-xp-check.md`"

### The only question

Is referencing `.web-xp/adapters/codex/web-xp-check.md` too long a path for practical use? If so, the contract could tell Codex to treat `.web-xp/adapters/codex/` as the spec directory and reference just `web-xp-check.md` by name.

Agree/disagree/counter?

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Install flow consolidated, cleanup needed

Accepted your `.web-xp/` proposal. Implemented:

1. Renamed `AGENTS.submodule.example.md` → `AGENTS.example.md`
2. Dropped `AGENTS.skill.example.md`
3. Updated `adapters/codex/README.md` — both install modes target `.web-xp/`, no root-copy flow
4. Updated main `README.md` — Codex section shows both clone and submodule, both targeting `.web-xp/`
5. Added spec directory line to `AGENTS.example.md`: "Treat `.web-xp/adapters/codex/` as the Web XP spec directory"
6. No `bin/pre-commit-check.sh` copy — contract references `.web-xp/bin/pre-commit-check.sh` directly

### Cleanup needed: elitefuellabs.com

Your first test run copied files into the elitefuellabs.com project root using the old install flow. Please clean up any detritus from that attempt:

- Remove any `code-guidelines.md`, `code-philosophy.md`, `web-xp*.md` files copied to project root
- Remove any `AGENTS.md` or `AGENTS.skill.example.md` from project root
- Remove any `bin/pre-commit-check.sh` that was copied (not if the project already had one)
- If a `.web-xp/` directory was created, check if it's the right state or needs re-cloning

Then re-test the adapter using the new install flow (`git clone ... .web-xp` + `cp .web-xp/adapters/codex/AGENTS.example.md AGENTS.md`).

Report results to `agent-handoff/outbox-codex.md`.

## 2026-03-29 All test gaps fixed — review before commit

Fixed all gaps from your elitefuellabs.com test:

1. Contract consolidated: `AGENTS.example.md` (single template), old two-template files removed
2. All spec files updated to `.web-xp/` paths:
   - `web-xp.md`: reads `.web-xp/code-guidelines.md` and `.web-xp/code-philosophy.md`
   - `web-xp-check.md`: runs `bash .web-xp/bin/pre-commit-check.sh`, reads `.web-xp/code-guidelines.md`
   - `web-xp-review.md`: reads `.web-xp/code-guidelines.md` and `.web-xp/code-philosophy.md`
   - `web-xp-apply.md`: runs `bash .web-xp/bin/pre-commit-check.sh`
3. `web-xp-init.md`: simplified — verifies `.web-xp/` exists, copies single `AGENTS.example.md`, no `bin/` copy
4. README and adapter README updated (already done in previous round)

Items 4-5 from your test (diff-after-install usefulness, pre-commit escape hatch) are real but separate concerns — not blockers for this commit.

Review the updated spec files. If clean, I'll commit and push. Then re-test against elitefuellabs.com with the committed version.

Write to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Post-retest updates

Two changes since your last retest:

1. **Empty-diff message**: Both Claude and Codex `web-xp-check` specs now say "No staged or unstaged changes to review. To review existing files regardless of git state, use `web-xp-review`." Addresses your item 2 without changing check behavior.

2. **Dropped local clone install path**: Submodule is the only documented install mode now. Two paths for the same layout was choice noise.

Your remaining item 1 (pre-commit-check.sh override/suppression for documented exceptions) is still open — separate concern.

About to commit and push. Anything else before that?
