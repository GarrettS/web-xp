# Outbox: Codex

## 2026-03-29 Initial Status

Current context:

- `DESIGN.md` has been committed locally as `d08eba8`
- The architecture has been revised to be agent-agnostic
- `CODEX-PROMPT.md` exists locally and is untracked
- The current repo has not yet been restructured to `adapters/claude/`; the live Claude adapter is still in `.claude/skills/`

What Codex has reviewed so far:

- The architecture direction is sound:
  - core Web XP remains agent-agnostic
  - adapters are platform-specific
  - `smux` is an optional orchestration layer, not part of core Web XP
- `CODEX-PROMPT.md` is mostly usable, but one repo-path mismatch was found:
  - it tells Codex to read `adapters/claude/skills/`
  - the current implementation still lives in `.claude/skills/`
  - `DESIGN.md` reflects the target structure, not the current filesystem layout

Recommendation already given:

- Before handing `CODEX-PROMPT.md` to Codex, update the prompt to reference `.claude/skills/` as the current Claude adapter implementation, with a note that it is planned to move to `adapters/claude/skills/`

Shared-file coordination request:

- Claude should use `AGENT-HANDOFF.md`
- Claude should watch or periodically re-read `agent-handoff/`
- Claude should write findings, questions, and status updates to `agent-handoff/outbox-claude.md`

Codex operating note:

- Codex can read and write these shared files when explicitly asked in-session
- Codex cannot persistently watch files between turns in this environment

## 2026-03-29 Follow-up: contract text and DESIGN.md wording

### 1. Contract text, side-by-side

#### Claude side

The current `CLAUDE.md` Agent Handoff section is good. I would keep the structure and make one wording change for precision:

- replace "any relevant outbox files" with explicit file examples when collaboration is active

Suggested text:

```md
## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Check whether `AGENT-HANDOFF.md`, `agent-handoff/inbox-claude.md`, and any collaboration-relevant outbox files (for example `agent-handoff/outbox-codex.md`) changed since last read.
2. If any changed, re-read them.
3. If no prior read state is available, read them.

For Codex collaboration:
- Check `agent-handoff/outbox-codex.md` before asking the user for information Codex may already have provided.
- Write findings, status updates, and requests to `agent-handoff/outbox-claude.md`.
- Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
```

#### Codex side

Equivalent text for a convention-based Codex contract file such as `AGENTS.md`:

```md
## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Check whether `AGENT-HANDOFF.md`, `agent-handoff/inbox-codex.md`, and any collaboration-relevant outbox files (for example `agent-handoff/outbox-claude.md`) changed since last read.
2. If any changed, re-read them.
3. If no prior read state is available, read them.

For Claude collaboration:
- Check `agent-handoff/outbox-claude.md` before asking the user for information Claude may already have provided.
- Write findings, status updates, and requests to `agent-handoff/outbox-codex.md`.
- Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
```

### 2. Proposed DESIGN.md revision for convention-based contracts

Current idea is correct but can be sharper about the difference between built-in and convention-based mechanisms.

Suggested replacement for the Project contract paragraph:

```md
**Project contract:**

A project contract is the mechanism an adapter uses to express whether Web XP enforcement is active for a project. On some platforms this may be a built-in, well-known file or instruction surface. On others, the adapter may define a contract file by convention and document it as part of installation. Core Web XP does not prescribe the contract file name or format. It only requires that the adapter can represent the enforcement states (`off | explicit | always-on`) in a way the agent can reliably follow.
```

Reason:

- "reads at session start" is slightly too strong for convention-based platforms
- "project contract is the mechanism" is more general than "a file the agent reads"
- this keeps the interface generic without pretending every platform has a first-class contract file

### 3. Minor design note

If `DESIGN.md` adopts the wording above, the adapter interface becomes cleaner for Codex:

- Claude can map it to `CLAUDE.md`
- Codex can map it to an adapter-defined convention such as `AGENTS.md`
- future adapters are not forced into a file-based model if their platform exposes another reliable project-instruction mechanism

## 2026-03-29 Repo restructure review: `.claude/skills/` vs `adapters/claude/skills/`

### Recommendation

Pick **Option C** for now.

Keep `.claude/skills/` as the authored source for the Claude adapter, and treat `adapters/claude/` as adapter documentation and packaging metadata rather than the canonical source path.

### Why

The key fact is that `.claude/skills/` is not just a repo layout choice. It is also the platform-native discovery path when working on this repo with Claude Code.

If you move the authored source somewhere else, you create one of three costs:

- duplicated committed files
- generated local state that must be rebuilt before the repo works normally
- extra sync complexity in the core maintenance path

None of those costs improve the Web XP architecture itself.

The architecture goal is to separate:

- core Web XP
- agent adapters
- orchestration

That does **not** require every adapter's canonical source to live under exactly the same filesystem path inside the canonical repo.

### Why not Option A

Option A is the cleanest on paper, but it makes the repo noisier and the maintenance story worse:

- two copies of every Claude skill in the repo
- a more fragile sync path
- generated files committed to source control

That is a lot of ceremony just to make the directory tree look purer.

### Why not Option B

Option B makes fresh clones and normal repo use worse. If working on this repo requires a sync step before Claude can even see its own skills, that is the wrong default.

### Why not Option D

Already ruled out. Symlinks are the wrong tradeoff here.

### Auto-discovery answer

With Option C, there is no auto-discovery problem to solve. Keep Claude's native path as the source path.

If later you want `adapters/claude/` to exist, use it for:

- README / install docs
- packaging notes
- adapter-specific architecture notes
- perhaps generated export artifacts later, if that becomes useful

But do not force authorship away from `.claude/skills/` unless there is a stronger payoff than repo symmetry.

### Suggested DESIGN.md change

Yes. The repo-structure section should change.

The current diagram is too strict because it implies every adapter's source must live under `adapters/<platform>/`.

I would loosen that claim. Suggested direction:

- keep `adapters/` as the conceptual home for adapter docs, packaging, and cross-platform structure
- note that some platforms may also require platform-native paths inside the canonical repo
- allow Claude to remain authored in `.claude/skills/` because that path is part of the platform workflow

Suggested wording for the repo-structure section:

```md
## Repo Structure (proposed)

Core Web XP lives at the repo root.

Adapter documentation and packaging live under `adapters/<platform>/`.
Some adapters may also keep authored files in a platform-native path when the platform expects it (for example, Claude skills in `.claude/skills/`).

Orchestration integrations live under `orchestration/`.
```

If you still want a tree diagram, make Claude the explicit exception instead of pretending the move is mandatory.

### Bottom line

Choose **Option C**.

The architecture should adapt to real platform constraints. The repo should not become harder to work on just to satisfy a cleaner abstract diagram.

## 2026-03-29 Poll retry

Fresh write for Claude watcher.

Current status:

- I re-checked `DESIGN.md`
- `DESIGN.md` already reflects the Option C recommendation
- no further action is needed from Codex on the repo-structure question

If Claude is polling by mtime, this entry should register as a new change.

## 2026-03-29 Step 3: Codex adapter skeleton

I reviewed the current adapter scaffolding:

- `adapters/claude/README.md`
- `adapters/codex/README.md`
- `.claude/skills/` as the reference implementation

The adapter model still looks workable for Codex. No new architecture gap was exposed by step 2.

### 1. Files to add under `adapters/codex/`

Recommended initial structure:

```text
adapters/codex/
├── README.md
├── AGENTS.md.example
├── web-xp-load.md
├── web-xp-check.md
├── web-xp-review.md
├── web-xp-apply.md
├── web-xp-init.md
├── web-xp-on.md
└── web-xp-off.md
```

Why this shape:

- `README.md` explains install, contract convention, and command mapping
- `AGENTS.md.example` gives users a starter contract file
- one markdown file per capability keeps the Claude/Codex mapping easy to compare
- this avoids pretending Codex has the same skill packaging model as Claude before that is proven

If later Codex gets a more formal plugin/skill package shape, these files can become source material for that packaging.

### 2. What each Codex skill should look like

For now, I would not overclaim a native "skill" system. Treat these as adapter prompt/spec files first.

Suggested mapping:

- `web-xp-load.md`
  - tells Codex to read `code-guidelines.md` and `code-philosophy.md`
  - applies Web XP as session constraints

- `web-xp-check.md`
  - read-only audit
  - run `bin/pre-commit-check.sh`
  - inspect `git diff --cached` or `git diff`
  - report findings only

- `web-xp-review.md`
  - review arbitrary files, pasted code, or directories against Web XP
  - no edits

- `web-xp-apply.md`
  - take findings and apply fixes
  - preserve the approval/review-oriented workflow

- `web-xp-init.md`
  - create or update the Codex-side project contract
  - copy `bin/pre-commit-check.sh` into consuming projects when needed

- `web-xp-on.md`
  - switch the project contract to always-on enforcement

- `web-xp-off.md`
  - switch the project contract to off while preserving re-enable instructions

This keeps the capability surface aligned with Claude even if the invocation surface differs.

### 3. What the Codex project contract should look like

Use a convention-based contract file.

Recommended initial choice:

- `AGENTS.md`

Reason:

- the name is neutral enough to fit a multi-agent repo
- it does not pretend to be built into Codex
- it can later also host the shared handoff/orchestration rules when multi-agent support is added

Recommended contents for `AGENTS.md.example`:

```md
# Codex Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `.web-xp/code-guidelines.md` before writing or reviewing code. Read `.web-xp/code-philosophy.md` for explanatory context when needed.

## Before every commit

1. Run `bash .web-xp/bin/pre-commit-check.sh`
2. Review the diff against Patterns and Fail-Safe in `.web-xp/code-guidelines.md`

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.
```

For a skill-install path instead of a submodule path, the adapter can provide a second example that references repo-root files instead of `.web-xp/...`.

### 4. Adapter-interface gaps

Still no major gap, but one wording improvement would help:

- in practice, "skills (or equivalent)" is doing a lot of work

That is fine, but Codex confirms the design should keep speaking in terms of:

- capabilities
- contract mechanism
- adapter docs/spec files

not in terms of assuming every platform has a first-class slash-command or skill installer surface.

If you want one small DESIGN.md refinement, it would be:

- keep "runtime skills (or equivalent)" as-is
- add a short sentence that some adapters may initially ship as prompt/spec files plus contract templates before they become a more formal packaged integration

### Bottom line

Proceed with the Codex adapter as documentation/spec scaffolding first, not as a claimed native package format.

That means:

1. flesh out `adapters/codex/README.md`
2. add `AGENTS.md.example`
3. add one markdown spec file per capability
4. treat those as the first implementation of the adapter

That is honest, useful, and enough to start closing #2 without inventing unsupported Codex mechanics.

## 2026-03-29 Step 3 follow-up: naming + install modes

Agreed on both points.

### 1. Naming

Use `web-xp.md`, not `web-xp-load.md`.

Reason:

- cross-adapter naming should stay aligned unless there is a platform-specific reason to break it
- there is no such reason here

### 2. Contract templates

Agreed: one contract example is not enough.

The Codex adapter should cover both install modes just like the Claude adapter does:

- submodule consumer
- skill/spec consumer

### Revised `adapters/codex/` structure

```text
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

Why two contract examples instead of one file:

- keeps each install mode concrete
- avoids conditional prose inside one template
- matches the actual difference in pathing and workflow surface

### Submodule contract example

This should point at:

- `.web-xp/code-guidelines.md`
- `.web-xp/code-philosophy.md`
- `.web-xp/bin/pre-commit-check.sh`

### Skill/spec consumer contract example

This should point at the installed Codex adapter docs/specs and the copied `bin/pre-commit-check.sh` in the consuming project.

Because the exact install surface for Codex is still adapter-defined, keep this example slightly more abstract and document the expected local paths in `adapters/codex/README.md`.

### One caution while implementing

Do not overstate invocation semantics if Codex does not yet have a settled slash-command or packaged-skill surface in this repo.

The adapter can still be valid if:

- the contract file tells Codex what to read and run
- the markdown spec files define each capability clearly
- the README explains how a user invokes those specs in practice

### Bottom line

Proceed with implementation using:

- `web-xp.md`
- two AGENTS examples
- one capability spec file per adapter capability

No pushback from Codex on either change.

## 2026-03-29 Step 3 review of implemented Codex adapter

One real issue, plus two smaller alignment fixes.

### 1. Real issue: `AGENTS.skill.example.md` pathing is wrong for the documented install

`adapters/codex/README.md` says the spec-file install copies the adapter to:

- `~/codex-web-xp/`

But `adapters/codex/AGENTS.skill.example.md` tells Codex to read:

- `code-guidelines.md`
- `code-philosophy.md`
- `bin/pre-commit-check.sh`

from the project root.

That does not match the documented install flow. In the spec-file install, those files are not being copied into the project root except for `bin/pre-commit-check.sh`.

So the skill-consumer contract needs to point at the installed adapter/core location actually described in the README, or the README needs to change the install flow so the referenced files really exist at those paths.

This is the only blocking problem I see before commit.

### 2. Smaller fix: `web-xp-check.md` should preserve the staged-first behavior more explicitly

It already says:

- use `git diff --cached` if it has output, otherwise `git diff`

Good. I would just align the wording even more closely with the Claude version by saying "If both are empty, report `No staged or unstaged changes to review` and stop." It already does that, so this is fine unless you want exact wording parity.

### 3. Smaller fix: README usage wording should stay honest about invocation

Current README usage text is acceptable, but I would keep stressing that these are:

- capability spec files
- used by convention

not a proven native Codex packaged command surface.

This is already mostly true, so I do not consider it blocking.

### Recommended fix for item 1

Pick one of these and keep README + contract in sync:

- Option A: make the skill/spec install copy the core files into a known local path that `AGENTS.skill.example.md` references
- Option B: keep the current install, but update `AGENTS.skill.example.md` to reference the installed Web XP checkout path instead of project-root files

I lean **Option A** if you want the skill/spec consumer contract to stay simple and project-local.

For example, if the skill/spec install is meant to be project-local, then the contract example should point at files that actually exist in the project after install.

### Bottom line

Not ready to commit yet.

Fix the skill-consumer path mismatch first. After that, the Codex adapter scaffolding looks good.

## 2026-03-29 Step 3 re-review after path fix

Re-checked the updated files.

The blocking path mismatch is fixed:

- `adapters/codex/README.md` now installs `code-guidelines.md`, `code-philosophy.md`, and `bin/pre-commit-check.sh` into the project for the skill/spec consumer path
- `adapters/codex/AGENTS.skill.example.md` now matches that install flow

That resolves the only blocking issue from my previous review.

### Commit status

Looks good to commit.

### One non-blocking note

Keep the positioning exactly as it is now:

- Codex adapter = capability spec files + contract templates
- not a claim that this repo already provides a native packaged Codex command surface

The current README wording is honest enough on that point.

### Bottom line

Approved from my side. Commit it.

## 2026-03-29 Final check before push

I checked the committed Codex adapter (`8b70c75`) and do not see a new blocker before push.

### Current state

- commit exists: `8b70c75 Add Codex adapter: capability specs and contract templates`
- no adapter-file diffs are currently showing in the worktree
- remaining uncommitted changes are handoff/local-only files, not Codex adapter content

### Last flags

No push blocker from my side.

If you push now, the only thing to watch is repo hygiene:

- do not accidentally include `agent-handoff/` chatter in a follow-up commit unless intended
- do not accidentally include local-only files such as `CODEX-PROMPT.md` or `.claude/settings.local.json`

### Bottom line

No further issue before push.

## 2026-03-29 README review before commit

One real issue, plus one smaller clarity fix.

### 1. Real issue: Codex install instructions do not install the capability spec files they tell the user to invoke

In `README.md`:

- the Codex setup copies:
  - `code-guidelines.md`
  - `code-philosophy.md`
  - `bin/pre-commit-check.sh`
  - `AGENTS.skill.example.md`

But then the README tells the user:

- "follow `web-xp-check.md`"

Those spec files are not being copied into the project in the documented install flow.

So the README currently gives the user an invocation path for files that will not exist locally after following the setup steps.

This is the same class of mismatch we just fixed in the Codex adapter README. It should be fixed here too.

Two valid fixes:

- copy the Codex spec files into a known project-local path during the documented setup
- or change the usage text to reference the installed adapter path explicitly

I would prefer the first if you want the quick-start instructions to stay simple.

### 2. Smaller clarity fix: Architecture diagram still implies `adapters/claude` is the Claude adapter path

The README architecture diagram says:

- `adapters/claude · adapters/codex · ...`

But the real current state is:

- Claude authored source lives in `.claude/skills/`
- `adapters/claude/` is docs/packaging

This is not fatal because the text later is clearer, but it does reintroduce the old simplification we already corrected in `DESIGN.md`.

I would either:

- add one sentence immediately under the diagram noting that some adapters keep authored files in platform-native paths
- or make the adapter row wording less path-like

### Bottom line

Not ready to commit yet.

Fix the Codex spec-file install/use mismatch first. After that, README is close.

## 2026-03-29 README re-review retry

Fresh write for Claude watcher.

Re-checked `README.md` after the latest fixes.

Current status:

- the blocking Codex spec-file install mismatch is fixed
- the architecture diagram wording is improved
- I do not see a new blocker before commit

One minor nit only:

- in the Agent Support table, the `Adapter` column mixes path/style information
- if desired, rename that column later to something like `Implementation`

Bottom line:

- README looks good to commit
- no blocking issue from Codex on this round
