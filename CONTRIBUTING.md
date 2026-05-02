# Contributing to Web XP

Thanks for your interest. Most contributions are edits to the doctrine itself or to the agent adapters.

> File-name note: GitHub recognizes `CONTRIBUTING.md` (singular, "-ING") as the contributor-guidelines file. `CONTRIBUTORS.md` is sometimes used as a credits list — a different file, not the one GitHub surfaces on issue and PR pages.

## What Web XP is

Web XP is doctrine + adapters + a pre-commit check. Doctrine is the standard; adapters teach specific agents (Claude, Codex, others) how to load and apply it; the pre-commit check enforces the mechanical subset. See [`README.md`](./README.md) for the project overview and [`DESIGN.md`](./DESIGN.md) for the architecture.

## Where to start

- [`help wanted`](https://github.com/GarrettS/web-xp/labels/help%20wanted) — issues open to outside contribution.
- [`good first issue`](https://github.com/GarrettS/web-xp/labels/good%20first%20issue) — well-scoped entry points.
- [`ready`](https://github.com/GarrettS/web-xp/labels/ready) — design has settled; implementation welcome.
- [`needs-design`](https://github.com/GarrettS/web-xp/labels/needs-design) — discussion welcome before code.

Read [`code-guidelines.md`](./code-guidelines.md) (the standard) and [`code-philosophy.md`](./code-philosophy.md) (interpretive context) before proposing changes to either. Most "new" rules turn out to be sharpenings of existing ones — name what's already there that you're extending.

## How doctrine is organized (metadoctrine)

Doctrine has four kinds of content. Knowing which your change is helps it land in the right place:

| Kind | Lives in | Purpose |
|------|----------|---------|
| **Stated doctrine** | `code-guidelines.md` | binding rules: what code must be; what a violation is |
| **Interpretive doctrine** | `code-philosophy.md` (current); being folded into `Note:` sections in `code-guidelines.md` per [#38](https://github.com/GarrettS/web-xp/issues/38) | why the rule exists; how to apply it in ambiguous cases |
| **Operational doctrine** | adapter skills, project contracts, `bin/pre-commit-check.sh` | how the rule is loaded, activated, and mechanically enforced |
| **Maintainer process** | [`MAINTAINERS.md`](./MAINTAINERS.md) | how maintainers operate the project itself |

Quick placement guide:

- States what code should be → stated doctrine.
- Explains why, or how to interpret in edge cases → interpretive doctrine.
- Loads, primes, activates, or mechanically checks → operational doctrine.
- Concerns build flow, release, or repo workflow → maintainer process.

The full decision procedure, anti-bleed rules, and propagation paths are in `MAINTAINERS.md`.

## Doctrine entry structure

Doctrine entries follow a family-level format (per [#33](https://github.com/GarrettS/web-xp/issues/33)). Use these subheads **where they apply** — don't force every section onto every rule:

- **Governing Statement** — the binding principle in shortest durable form.
- **Core Distinctions** — definitions and boundaries.
- **Examples** — a canonical worked example.
- **Violations** — Wrong / Explanation / Right / `Pattern` or `Code smell`.
- **Exceptions** — allowed exception forms.
- **Reference Examples** — longer examples or troubleshooting.
- **Related Rules / Related Sections** — cross-links to adjacent doctrine.

Live examples to read first: **Fail-Safe** (fuller structure) and **Ubiquitous Language** (lighter, omitting sections the rule doesn't need).

### Enforcement triggers

Inside **Violations**, two trigger kinds exist:

- **`Pattern`** — mechanically detectable (e.g. `.find(...)` comparing to a known id). A match is a candidate; review confirms or rules out.
- **`Code smell`** — contextual; requires judgment. Greedy by nature; report selectively in human-agent pairing.

Triggers flag code for review; they do not prescribe automatic fixes.

### `Note:` for informative text

Use the `Note:` tag inside an entry for explanatory text agents should skip during priming and read during review or pairing. If a `Note:` implies a requirement, move the requirement into the rule text.

## Doctrine change flow

1. **Open an issue.** Tag with `doctrine`. State the gap, the proposed change, and the case that motivated it. A real-world misapplication is the strongest motivation.
2. **Discuss.** Doctrine is load-bearing — framing gets refined before any text lands.
3. **Draft.** Drafts in progress can live in `drafts/*-issue-draft.md` until the framing settles.
4. **PR** once the issue is `ready`. Keep the PR focused on one entry. Edit `code-guidelines.md` for stated doctrine; edit `code-philosophy.md` for interpretive doctrine (until [#38](https://github.com/GarrettS/web-xp/issues/38) lands).
5. **Propagation check.** Doctrine changes ripple. If your stated-doctrine change adds a term or shifts framing, check whether interpretive material, operational summaries, or skill prose need adjustment.

State in the PR description whether the metadoctrine changed or held — see `MAINTAINERS.md` for what that means.

## Reviewing code against doctrine

A doctrine-grounded review is not a flat smell list. The four-step sequence (per [#44](https://github.com/GarrettS/web-xp/issues/44)):

1. **Classify** — name the concerns in the module and whether they're entangled.
2. **Untangle** — when concerns are entangled, decide which seams to create before local fixes apply.
3. **Apply insight (solo)** — produce a doctrine-rooted prioritized list. Each item names the doctrine rule it cites; downstream items name upstream dependencies.
4. **Apply insight (interactive)** — walk the list with the user, reasoning from doctrine. The output is the final prioritized list.

This is the shape `web-xp-review` and `web-xp-check` aim for, not a flat lint dump.

## Running checks before commit

```bash
bash tools/check-web-xp-sync.sh    # rebuilds generated adapter skills from shared sources
bash bin/pre-commit-check.sh       # mechanical violations
bash test/run-unit.sh              # Bats unit tests (one-time: brew install bats-core)
```

If you're in a project with Web XP enabled, run `/web-xp-check` (Claude Code) or `web-xp-check` (Codex) to audit the current diff against the doctrine.

## Adapter changes

Web XP is agent-agnostic — one doctrine, multiple adapters.

**Always edit the shared source, never the generated adapter output.**

- Canonical: `adapters/shared-base/skills/`
- Generated (built from shared source by `tools/build-adapter-skills.sh`): `adapters/claude/`, `adapters/codex/skills/`
- Runtime install paths (populated by `bin/install.sh`): `~/.claude/skills/`, `$HOME/.agents/skills/`

If you're adding support for a new agent platform, see the **Agent Adapter Interface** section in [`DESIGN.md`](./DESIGN.md) for the required runtime and setup capabilities, and the **Building a new adapter** section in [`MAINTAINERS.md`](./MAINTAINERS.md) for the build chain.

## For maintainers

Operational details — adapter packaging, build flow, install/uninstall internals, release process, agent-handoff protocol — live in [`MAINTAINERS.md`](./MAINTAINERS.md). Most contributions don't need that depth; cross it when your work touches `adapters/`, `tools/`, or `bin/install.sh`.

For the architecture (enforcement modes, runtime roles, orchestration topologies, adapter interface), see [`DESIGN.md`](./DESIGN.md).

## Code of conduct

Be respectful. Critique ideas, not people. Doctrine work involves a lot of "this framing isn't quite right yet" — that's the whole point.
