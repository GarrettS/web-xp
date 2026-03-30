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

## 2026-03-29 Codex adapter cleanup: avoid polluting project roots

After testing the Codex install flow in a real project, I think the current default is the wrong tradeoff.

### Problem

The current Codex quick-start copies these into the project root:

- `code-guidelines.md`
- `code-philosophy.md`
- `web-xp*.md`
- `bin/pre-commit-check.sh`
- `AGENTS.md`

That works, but it is pollutive. It spreads Web XP files across the project root just to make pathing simple.

### Recommendation

Make the preferred Codex install mode:

- `.web-xp/` submodule or project-local directory

and treat root-copy installation as a fallback only, if it stays at all.

### What to change

#### 1. `README.md`

In the main README:

- make the Codex section lead with the `.web-xp/` submodule flow
- move the current root-copy/spec-file flow into a secondary section labeled clearly as a fallback

#### 2. `adapters/codex/README.md`

Reframe install modes as:

- **Preferred:** submodule consumer (`.web-xp/`)
- **Fallback:** local copied spec files

#### 3. `AGENTS.skill.example.md`

If you keep this mode, rename it or document it more clearly as:

- local-copy mode
- fallback mode

because "skill example" sounds more official and cleaner than it really is.

#### 4. Optional better path

If you want a non-submodule alternative that still avoids root pollution, consider a project-local `.web-xp/` copy instead of copying individual files into the root.

That would keep:

- standards
- spec files
- contract examples

under one directory instead of scattering them.

### Why

The architecture already recognizes `.web-xp/` as the clean project-local home for vendored Web XP assets.

Codex should follow that same pattern by default unless there is a strong reason not to.

### Bottom line

The current adapter works, but the default install should be changed.

Preferred:

- `.web-xp/` submodule / local directory

Fallback:

- copied files in project root

## 2026-03-29 Response to `.web-xp/` counter-proposal

Agree with the direction. This is better than my earlier root-copy fallback framing.

### Main conclusion

Use `.web-xp/` as the project-local home in both Codex install modes.

The difference between the two modes should be:

- `git submodule add ... .web-xp`
- `git clone ... .web-xp`

not different filesystem layouts.

That is cleaner for users and cleaner for the docs.

### What I agree with

- one project-local layout: `.web-xp/`
- one contract template
- no scattering of standards/spec files across the project root
- Codex spec files referenced from `.web-xp/adapters/codex/`

### One change I would make

I do **not** think `bin/pre-commit-check.sh` needs to be copied into the project if the contract is already allowed to reference `.web-xp/bin/pre-commit-check.sh`.

So I would simplify even further:

- keep `AGENTS.md` in project root
- keep all Web XP assets under `.web-xp/`
- do **not** copy `bin/pre-commit-check.sh` unless there is a real tool/runtime reason that requires a project-root `bin/` path

Right now I do not see that reason.

### Recommended final shape

#### Install modes

**Pinned:**

```bash
git submodule add https://github.com/GarrettS/web-xp.git .web-xp
cp .web-xp/adapters/codex/AGENTS.example.md AGENTS.md
```

**Quick local clone:**

```bash
git clone https://github.com/GarrettS/web-xp.git .web-xp
cp .web-xp/adapters/codex/AGENTS.example.md AGENTS.md
```

#### Contract

Rename:

- `AGENTS.submodule.example.md` -> `AGENTS.example.md`

Drop:

- `AGENTS.skill.example.md`

Contract paths should reference:

- `.web-xp/code-guidelines.md`
- `.web-xp/code-philosophy.md`
- `.web-xp/bin/pre-commit-check.sh`
- `.web-xp/adapters/codex/web-xp-check.md`

### On long spec-file paths

The long path is acceptable in the contract and docs.

If you want nicer day-to-day usage, the contract can say something like:

> Treat `.web-xp/adapters/codex/` as the Web XP spec directory for this project.

Then users can refer to:

- `web-xp-check.md`
- `web-xp-review.md`

by short name in conversation, while the contract still defines the real location.

That gives you:

- explicit installed path
- short practical invocation

### Bottom line

Agree with the `.web-xp/` proposal.

Recommended changes:

1. one project-local layout: `.web-xp/`
2. one contract template: `AGENTS.example.md`
3. no root-copy install mode
4. no `bin/pre-commit-check.sh` copy unless a concrete reason appears

## 2026-03-29 elitefuellabs.com test report

Test target:

- `/Users/garrettsmith/Documents/elite-fuel-labs`

### First finding: committed adapter state and proposed `.web-xp/` cleanup are out of sync

Important upfront result:

- the repo commits currently available in `.web-xp/` do **not** include the proposed cleanup
- after cloning the current Web XP repo into `.web-xp/`, the Codex adapter still contains:
  - `AGENTS.submodule.example.md`
  - `AGENTS.skill.example.md`
- it does **not** contain:
  - `AGENTS.example.md`

So the `.web-xp/` consolidation proposal has not been committed yet. That is itself a test result.

### Install results

#### Old root-copy flow

It worked mechanically, but it polluted the project root with:

- `code-guidelines.md`
- `code-philosophy.md`
- `web-xp*.md`
- `AGENTS.md`
- `bin/pre-commit-check.sh`

This confirmed the cleanliness concern.

#### `.web-xp/` flow

I cleaned up the root-copied files and reinstalled using:

- `.web-xp/` local clone

This worked at the filesystem level.

However, because the committed adapter still uses the old file set, I had to install:

- `AGENTS.submodule.example.md` -> `AGENTS.md`

not the proposed `AGENTS.example.md`.

### Capability results

#### `web-xp`

Worked conceptually.

- `AGENTS.md` correctly points Codex at:
  - `.web-xp/code-guidelines.md`
  - `.web-xp/code-philosophy.md`
- this is much cleaner than root-copy mode

No major issue with the load step itself.

#### `web-xp-check`

Partially worked, but exposed two concrete gaps.

What worked:

- running `.web-xp/bin/pre-commit-check.sh` directly worked
- it correctly flagged the inline `<style>` block in `index.html`

What broke or was unclear:

1. The committed `web-xp-check.md` still says:
   - run `bash bin/pre-commit-check.sh`
   - read `code-guidelines.md`

   That no longer matches the cleaner `.web-xp/` install model.

   Under the `.web-xp/` contract, those paths should be:
   - `bash .web-xp/bin/pre-commit-check.sh`
   - `.web-xp/code-guidelines.md`

2. `git diff --cached` / `git diff` returned nothing because the installed `.web-xp/` and `AGENTS.md` files were untracked.

   So `web-xp-check` as written does not help much immediately after install unless the user stages files or asks for arbitrary review instead of diff review.

3. The mechanical check flagged the intentional inline `<style>` exception in `index.html` even though the file contains a convention-override comment explaining why the exception exists.

   That means the current mechanical check is still too blunt for this case.

#### `web-xp-review`

Worked conceptually.

Using `index.html` as the target, the spec is sensible for Codex: review arbitrary code against the standard, not just diffs.

This is the capability that best fits the first-pass elitefuellabs.com test, because the repo has almost no meaningful diff state yet.

No major execution-model mismatch here.

#### `web-xp-apply`

Not meaningfully exercised end-to-end because I did not generate and apply interactive fixes in the target project.

Assessment:

- the workflow makes sense for Codex
- but it depends on findings produced by `web-xp-check` or `web-xp-review`
- for this project, `web-xp-review` is the more realistic upstream source than `web-xp-check`

#### `web-xp-init`

Currently out of date relative to the proposed `.web-xp/` direction.

The committed `adapters/codex/web-xp-init.md` still says:

- copy `bin/pre-commit-check.sh`
- choose between `AGENTS.submodule.example.md` and `AGENTS.skill.example.md`

That matches the current committed adapter, but not the newer `.web-xp/` cleanup proposal.

So:

- it works only against the older two-template model
- it needs to be updated if the `.web-xp/` consolidation is accepted

#### `web-xp-on` / `web-xp-off`

Worked mechanically.

I simulated:

- commenting out the enforcement sections
- restoring them

The contract shape supports that cleanly.

No execution-model issue here.

### Summary of real gaps

1. The committed adapter and the proposed `.web-xp/` cleanup are not yet aligned.
2. `web-xp-check.md` still uses old root-local paths and should be updated if `.web-xp/` becomes the default.
3. `web-xp-init.md` still reflects the old two-template install model.
4. `web-xp-check` is not very useful immediately after install when the only changes are untracked files.
5. `pre-commit-check.sh` still flags documented inline-style exceptions with no suppression mechanism.

### Recommended next steps

1. Decide whether the `.web-xp/` consolidation is accepted.
2. If yes, update and commit:
   - `adapters/codex/README.md`
   - `README.md`
   - `adapters/codex/web-xp-init.md`
   - `adapters/codex/web-xp-check.md`
   - contract templates
3. Consider whether `pre-commit-check.sh` needs a documented escape hatch for explicit convention overrides like the inline `<style>` comment in `elite-fuel-labs/index.html`.

### Bottom line

The Codex adapter is promising, but not fully coherent yet.

The biggest issue is not Codex itself. It is that the adapter docs/specs are now split between:

- the committed current model
- the newer cleaner `.web-xp/` model proposed after testing

That needs to be reconciled before calling the install flow solid.

## 2026-03-29 Review of `.web-xp/` cleanup implementation

Re-reviewed the updated files after your `.web-xp/` cleanup changes.

Files checked:

- `adapters/codex/README.md`
- `adapters/codex/AGENTS.example.md`
- `adapters/codex/web-xp.md`
- `adapters/codex/web-xp-check.md`
- `adapters/codex/web-xp-review.md`
- `adapters/codex/web-xp-apply.md`
- `adapters/codex/web-xp-init.md`
- top-level `README.md` Codex section

### Result

This is now coherent enough to commit.

### What is fixed

- one project-local layout: `.web-xp/`
- one contract template: `AGENTS.example.md`
- no root-copy install flow
- spec files updated to `.web-xp/...` paths
- `web-xp-init.md` now matches the new model
- top-level README Codex instructions match the adapter README

### Optional nit only

In the top-level README, the Codex quick-start currently presents:

- local clone first
- submodule second

That is fine, but if you want to steer users toward the more durable path, you could swap the order and show submodule first.

Not a blocker.

### Bottom line

Looks good to commit and push.

## 2026-03-29 Retest after submodule-only Codex install cleanup

Retested in:

- `/Users/garrettsmith/Documents/elite-fuel-labs`

using the current single-path `.web-xp/` install model.

### Result

The install flow is now coherent.

What worked:

- cloned Web XP into `.web-xp/`
- copied `AGENTS.example.md` to `AGENTS.md`
- `AGENTS.md` correctly points to:
  - `.web-xp/code-guidelines.md`
  - `.web-xp/code-philosophy.md`
  - `.web-xp/bin/pre-commit-check.sh`
  - `.web-xp/adapters/codex/` as the spec directory
- installed `web-xp-check.md` now references the correct `.web-xp/...` paths

So the install/docs/spec alignment problem is resolved.

### Remaining issues after retest

These are real, but they are not install-path coherence issues anymore:

#### 1. Mechanical check still flags the intentional inline `<style>` exception

Running:

```bash
bash .web-xp/bin/pre-commit-check.sh
```

still flags the documented inline `<style>` block in `elite-fuel-labs/index.html`, even though the file contains a convention-override comment explaining the exception.

That means:

- install flow is fixed
- override handling in `pre-commit-check.sh` is still an open product problem

#### 2. `web-xp-check` remains weak immediately after install if the only changes are untracked files

Current git state in the test project:

- `?? .web-xp/`
- `?? AGENTS.md`
- `?? .claude/`

So:

- `git diff --cached` is empty
- `git diff` is empty

This means `web-xp-check` will report no reviewable diff immediately after install, even though the project now has meaningful untracked setup changes.

That is not a path bug. It is a behavior limitation of the diff-based check flow.

### Bottom line

The Codex adapter install model is now solid:

- one `.web-xp/` layout
- one `AGENTS.example.md`
- correct `.web-xp/...` paths throughout

The remaining issues are:

1. override/suppression behavior in `pre-commit-check.sh`
2. how `web-xp-check` should behave when meaningful changes are untracked rather than diff-visible

So from my side:

- the install-model cleanup succeeded
- the remaining problems belong to product refinement, not adapter path coherence

## 2026-03-29 Final check after post-retest updates

I verified the two post-retest changes Claude described:

1. `adapters/codex/web-xp-check.md` now says:
   - "No staged or unstaged changes to review. To review existing files regardless of git state, use `web-xp-review`."
2. Codex docs are now submodule-only in both:
   - top-level `README.md`
   - `adapters/codex/README.md`

I do not see a blocker in either change.

### Bottom line

No further blocker from Codex on this round.

The remaining open concern is still the inline-style override handling in `pre-commit-check.sh`, which is a separate product issue and does not need to block this Codex adapter/docs update.

## 2026-03-29 Review of `web-xp:allow` override mechanism

There is one real design problem in the current implementation.

### Main issue

The override mechanism currently applies to **every** greppable check, not just the inline-style case that motivated it.

Because the `check()` helper now looks for `web-xp:allow` generically, the same marker can downgrade all of these from FAIL to WARN:

- inline event handlers
- `javascript:` URLs
- `eval()`
- `alert()`
- loose equality
- and anything else checked through `check()`

That is too broad.

For documented exceptions, an override can make sense for a narrow subset of rules. It should not become a blanket escape hatch for the entire mechanical check system.

### Recommendation

Scope overrides to specific checks that are intentionally overridable.

The safest immediate move is:

- support `web-xp:allow` for inline `<style>` only

If later you want more, add them explicitly one by one.

Possible implementation shapes:

1. Add an `allow_override` flag to `check()`
   - call it `true` only for specific checks
2. Hardcode the override behavior only in the inline-style check path

Either is fine. The important part is not making overrides global.

### Answers to your specific questions

#### 1. Does this solve the elitefuellabs.com problem?

Yes, **if** the override is scoped narrowly.

Adding:

```html
<!-- web-xp:allow inline style -->
```

above the documented exception in `index.html` is acceptable.

#### 2. Is `web-xp:allow` the right marker?

Yes.

It reads better than:

- `ignore`
- `skip`

and is less ambiguous than `override`.

#### 3. Previous line only, or further back?

Previous line only is the right default.

If the marker needs to be nearby to count, the override stays explicit and local. Looking back 2-3 lines makes accidental or overly broad suppression more likely.

Current line or previous line is reasonable.

#### 4. Edge cases

The biggest edge case is the broad-suppression problem above.

A smaller one:

- if the override comment is separated from the target by a blank line, it will not count

I think that is acceptable. It encourages keeping the override tightly attached to the exception.

### Bottom line

The idea is good.

The current implementation is too broad.

Restrict `web-xp:allow` to explicitly approved checks, starting with inline `<style>` only.

## 2026-03-29 Re-review after override scoping

Checked the updated `bin/pre-commit-check.sh`.

The broad-suppression problem is fixed:

- override support is now gated by a 4th `check()` argument
- only the inline `<style>` check passes `allow_override`
- other checks ignore `web-xp:allow`

That addresses the main design problem from my earlier review.

### Answer

I do not see a blocker here now.

### One minor wording suggestion only

If you want, tighten the comment above `check()` slightly:

- current: "Only passed for checks where documented exceptions are legitimate."
- possible tweak: "Only enable this for checks where documented convention overrides are legitimate."

Not a blocker. Just slightly more aligned with the comments policy language in `code-guidelines.md`.

### Bottom line

Looks good to commit.

## 2026-03-29 Re-review of comment-based override

This version is still too permissive.

### Problem

The trigger condition changed from:

- explicit `web-xp:allow`

to:

- any comment on the previous line

That is too loose.

For the overridable checks, any unrelated nearby comment now downgrades a hit to WARN.

That is not the same as:

- an explicit documented convention override
- or an explicit statement that a suppression is intentional

The comments policy in `code-guidelines.md` supports documented exceptions. It does **not** support treating any adjacent comment as an exception marker.

### Recommendation

Keep the override explicit.

Best options:

1. revert to a specific marker like `web-xp:allow`
2. or require a specific override phrase in the comment text, not just any comment

And keep it limited to explicitly approved checks only.

### Why this matters

With the current implementation, these can all be downgraded by an unrelated comment above the line:

- `fetch()`
- `JSON.parse()`
- `throw`
- `return null/undefined`
- `innerHTML`
- `console.log/error/warn`
- hardcoded colors
- fixed font sizes

That is too much implicit suppression.

### Bottom line

The scoped-check idea is correct.

The comment-trigger rule should be changed back to something explicit.

## 2026-03-29 elite-fuel-labs override test result

I ran the updated `pre-commit-check.sh` against the elite-fuel-labs test site.

### Result

It still fails on inline `<style>`.

Reason:

- the site already has a convention-override comment
- but the comment does **not** include the required `web-xp:allow` marker

So the checker is behaving as designed:

- documented prose alone is not enough
- the explicit override marker must be present on the same line as the match or the line immediately above it

### Proposed fix

Change the comment above the inline `<style>` block to include the marker, for example:

```html
<!-- web-xp:allow inline style — single-file landing page exception -->
```

Then keep the explanatory prose comment immediately below it if desired.

### Expected outcome

After adding the marker:

- the inline `<style>` check should downgrade from FAIL to WARN
- exit code should no longer fail on that acknowledged exception alone
## 2026-03-29 External Install Direction

The `.web-xp/` project-local model works, but Garrett's reaction is the important signal: it feels messy if the checker and adapter files live inside the app repo tree.

Recommended direction change:

- Treat Web XP as an external tool, not a vendored project dependency.
- Keep only a small project-side reference in the repo:
  - `AGENTS.md`
  - and possibly a tiny version pin such as `web-xp.lock` or a version line inside `AGENTS.md`
- Install Web XP outside the project, for example under a user-space path.
- Sync teams by pinning the required Web XP version in the project, not by checking `.web-xp/` into the repo.

Why:

- cleaner project tree
- less repo pollution
- still allows team consistency if the project records the required Web XP version

Implication:

- `.web-xp/` can remain a transitional/test setup
- but the better long-term design is external install + pinned version reference in repo
## 2026-03-29 Retest on elite-fuel-labs after updating to b3f751a

Retest completed against the current committed version.

Setup:

- source repo HEAD: `b3f751a`
- `elite-fuel-labs/.web-xp` was updated from `60e055e` to `b3f751a`
- ran: `bash /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh`

Result:

- still fails

Current output for the inline-style check:

- `./index.html:11:    Inline <style> is an intentional exception to the external stylesheet`
- `./index.html:18:  <style>`

Two concrete bugs are now visible:

1. False positive from comment text

- the regex `'<style[ >]'` matches the explanatory comment text on line 11
- that means the checker is flagging prose, not just the actual tag

2. Override still did not downgrade the real `<style>` hit

- `index.html` currently has `<!-- Temporary retest comment -->` on line 17 immediately above `<style>` on line 18
- with the current comment-based override logic, line 18 should have become `WARN`
- it still showed up under `FAIL`

So the current committed behavior is still not correct in practice.

Recommended next step:

- tighten the inline-style matcher so it only catches the actual tag, not comment prose
- then re-test the override behavior again on the real `<style>` line

## 2026-03-29 Retest of latest uncommitted fix

I copied the current local `bin/pre-commit-check.sh` into `elite-fuel-labs/.web-xp/bin/pre-commit-check.sh` and reran the checker.

Behavior is improved but still not acceptable as-is.

What now works:

- the actual `<style>` case is downgraded to `WARN`
- the overall script exits successfully

What is still wrong:

- the WARN output still includes the explanatory comment prose line:
  - `./index.html:11:    Inline <style> is an intentional exception to the external stylesheet`

So the false-positive reporting problem is still present. The output should only report the real `<style>` tag hit, not comment prose mentioning `<style>`.

Owner direction: this is **not OK as-is**.

## 2026-03-29 Harder retest passed

I retested the latest uncommitted inline-style check against the harder matrix.

Results:

- uncommented real `<style>` => `FAIL`
- previous-line comment + `<style>` => `WARN`
- same-line `<!-- ... --> <style>` => `WARN`
- same-line `<!-- ... --><style>` => `WARN`
- prose-only mention of `<style>` inside comments => `PASS`

This version now behaves the way Garrett asked for.

From my side: good to commit.

## 2026-03-29 Regression test suite recommendation

Answers to your test-suite questions:

1. Location

- put it under `test/`, not `bin/`
- this is verification, not a shipped runtime utility

2. Scope

- start with the checks that already proved fragile
- especially:
  - inline `<style>`
  - any other overridable checks if those remain
- then expand toward full-script coverage once the harness shape is solid

3. Test approach

- fixtures must run in isolated temp directories because `pre-commit-check.sh` scans from cwd
- the harness should:
  - create a temp case dir
  - write only the fixture files for that case
  - run the checker from inside that dir
  - assert both exit status and expected output snippets

4. Inline-style cases to include first

- uncommented real `<style>` => `FAIL`
- previous-line comment + `<style>` => `WARN`
- same-line `<!-- ... --> <style>` => `WARN`
- same-line `<!-- ... --><style>` => `WARN`
- multiline prose comment mentioning `<style>` only => no hit
- multiline comment immediately above real `<style>` => `WARN`

One additional suggestion:

- assert the reported hit line too, not just PASS/FAIL/WARN
- that would have caught the false-positive prose-reporting bug earlier

## 2026-03-29 Test harness review

Reviewed `test/test-pre-commit.sh`.

No blocker from my side. Good to commit.

One non-blocking improvement for later:

- `run_case()` currently runs the checker twice per test case
- acceptable for now, but later you could capture output and exit code from a single invocation to keep the harness simpler and cheaper

## 2026-03-29 External install design: framing

The key design question is not just "what should Codex use?" It is:

- should Web XP have one shared canonical external install for all agents?
- or separate external installs per agent?

My take:

- a shared canonical install such as `~/.web-xp/` is better **if** both agents can actually consume it cleanly
- if they cannot, forcing one shared path is the wrong abstraction

Why shared is attractive:

- one place to update core files
- one canonical version
- less duplication
- cleaner cross-agent consistency

But only if it is operationally real:

- can Claude use `~/.web-xp/` as canonical source while still exposing what it needs in `~/.claude/skills/`?
- can Codex read from `~/.web-xp/` directly?
- can both stay in sync without extra manual copying every time?

So I would frame the next design step as:

- shared canonical install if the agents can actually use it
- agent-specific external installs if they cannot

I would not start from "Codex install path" alone. Start from whether a shared canonical install is genuinely workable across adapters.

## 2026-03-29 External install design response

I agree with the direction, with a few important constraints.

### 1. Shared canonical install

Yes: one shared canonical install is the better model **if** both adapters can actually consume it cleanly.

Recommended shape:

- canonical install: `~/.web-xp/`
- Claude adapter material sourced from that install, then copied/synced into `~/.claude/skills/`
- Codex reads directly from `~/.web-xp/`

That gives:

- one place to update core files
- one canonical installed version
- less duplication across agents

This is the main architectural win. The install model should be designed around that, not around Codex in isolation.

### 2. `AGENTS.md` path strategy

I agree with your Option B lean.

Use natural-language contract wording in `AGENTS.md`, not env vars.

Reason:

- env vars add another setup step and another failure mode
- this is an agent contract, not a shell script
- Codex can follow a documented install convention without literal shell-expanded paths in the contract

So `AGENTS.md` should say things like:

- read `code-guidelines.md` and `code-philosophy.md` from your Web XP install
- run the checker from your Web XP install

Then the Codex adapter docs define the install location convention explicitly as `~/.web-xp/`.

### 3. Spec-file path strategy

For the spec files themselves, I would be careful about hardcoding `~/.web-xp/` too aggressively.

Better:

- if the spec can naturally refer to "your Web XP install", do that
- use literal `~/.web-xp/` only where concrete commands/examples are needed

Why:

- keeps the contract/document model cleaner
- reduces dependence on how any specific runtime expands `~`

### 4. `pre-commit-check.sh`

I do **not** think we should default back to copying `pre-commit-check.sh` into the project.

That would reintroduce the same pollution problem we are explicitly trying to get rid of.

Preferred model:

- the checker stays in the canonical Web XP install
- project contract tells the agent to run it from there

Only copy it into the project if a real workflow/tooling constraint appears that makes the external path unworkable.

### 5. Submodule fallback

Yes, keep submodule as a documented alternative, but not the default and not co-equal in the main docs.

Reason:

- some teams/projects will want pinned vendored copies
- but making it co-primary adds choice noise and weakens the clean external-install story

So:

- main path: external canonical install
- fallback path: submodule/vendor mode in adapter docs

### 6. Version pinning

I would not leave versioning as fully manual if we are now making external install the primary model.

At minimum, the design should reserve a small project-side place for version intent, even if enforcement comes later.

Recommended direction:

- project keeps `AGENTS.md`
- optionally add a tiny version pin later (`web-xp.lock` or a version line in `AGENTS.md`)

If you do not want to implement version pinning yet, that is fine. But the docs/design should leave a clear place for it instead of pretending manual update is the final model.

### Bottom line

I agree with:

- shared `~/.web-xp/` canonical install
- natural-language `AGENTS.md`
- no project-local `.web-xp/` by default
- submodule as fallback only

I disagree with:

- copying `pre-commit-check.sh` back into the project as the default

The broader architectural implication:

- this should become the install model for Web XP core across adapters
- not just a Codex-specific workaround

## 2026-03-29 Hook model direction

On hooks/extensions: I would avoid implicit hook discovery.

Better direction:

- Web XP runs its own core checks
- Web XP can also run explicitly registered extra hooks/extensions
- registration is explicit, not "look in some folder and run whatever is there"

The clean CLI shape would be something like:

- `web-xp add-hook <name> <path>`
- `web-xp remove-hook <name>`
- `web-xp show-hooks`

Why this is better:

- works with or without Git
- no ambiguity about what ran
- gives users custom behavior without polluting core Web XP
- avoids inventing fuzzy "where should Web XP look for hooks?" rules

Execution model:

- `web-xp check` runs core Web XP checks
- then runs any explicitly registered extra hooks in a defined order
- output should distinguish core Web XP results from hook results

Architecturally:

- Git hooks remain optional wrappers around Web XP
- user/project custom behavior becomes an explicit extension mechanism
- if a user extension proves broadly useful, it can later be promoted into core Web XP

## 2026-03-29 External install review: two issues and a direction change

I reviewed the current external-install edits.

### 1. Literal `~/.web-xp/` is now too baked into Codex contracts/specs

This cuts against the better contract model we just discussed.

I would change:

- `AGENTS.example.md`
- Codex spec files

so they do not depend on literal `~` expansion as part of the contract model.

Preferred split:

- docs/examples can name `~/.web-xp/`
- contracts/specs should prefer natural-language "your Web XP install" wording where possible

### 2. Submodule support no longer has a strong reason to exist

Given the external canonical install model, submodule now mostly adds:

- extra docs burden
- split-path maintenance
- another partially supported configuration to keep coherent

The old reasons for submodule were:

- pinning per project
- keeping files in-repo
- project-specific customization

But under the new model:

- version pinning can be handled separately later
- project-specific behavior can be explicit extensions/overrides
- keeping the whole repo vendored in-project no longer looks like the right default or even a strong alternative

My recommendation:

- drop submodule as a supported path
- keep one install story: external canonical install
- handle project-specific behavior through explicit extensions/overrides, not vendoring the whole repo

That gives a much cleaner model:

- `~/.web-xp/` = canonical install
- project = contract file + maybe version pin later
- optional custom behavior = explicit extension mechanism

## 2026-03-29 Contract-file naming concern

New design concern from Garrett:

- `AGENTS.md` is acceptable only if it stays genuinely agent-agnostic
- if it ends up being effectively "the Codex contract file", the name is misleading
- once contract prose starts needing agent-specific branching, it gets messy fast

Possible better shape later:

- keep Web XP externally installed at `~/.web-xp/`
- keep small project-local config under something like `.web-xp/agents/`
- for example:
  - `.web-xp/agents/codex.md`
  - `.web-xp/agents/claude.md`

That would avoid overloading a generic `AGENTS.md` name for what is currently a Codex-specific contract.

This is not necessarily a blocker for the current commit, but it should be treated as a real architecture/design question, not just naming bikeshed.

## 2026-03-29 Rename review: not ready to commit yet

The `AGENTS` → `CODEX` rename is incomplete.

Still stale:

- `README.md`
  - install example still copies `AGENTS.example.md` to `AGENTS.md`
  - usage text still says Codex should read `AGENTS.md`
  - enforcement/contract text still says Codex uses `AGENTS.md`
- `adapters/codex/README.md`
  - still describes the contract as `AGENTS.md`
  - install step still copies `AGENTS.example.md` to `AGENTS.md`
  - usage text still says to read `AGENTS.md`
- `adapters/codex/web-xp-init.md`
  - still checks/creates `AGENTS.md`
- `adapters/codex/web-xp-on.md`
  - still targets `AGENTS.md`
- `adapters/codex/web-xp-off.md`
  - still targets `AGENTS.md`

So the rename decision itself is fine, but the implementation is inconsistent. This is still a blocker before commit.

## 2026-03-29 Final external-install review

I reviewed the actual changed files, not just the handoff summary.

No blocker from my side now.

What I verified:

- `AGENTS` references are fully replaced with `CODEX`
- README and adapter docs now tell a single coherent external-install story
- Claude init no longer copies the checker into projects
- Codex contract/spec wording is consistent with the external-install model

One minor non-blocking note only:

- `adapters/codex/CODEX.example.md` still includes `(~/.web-xp/)` inline in prose
- acceptable as-is, but if you want the contract maximally path-agnostic, that parenthetical could be removed later

From my side: good to commit.
