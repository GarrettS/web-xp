# Triage Strategy

The following prompt synthesizes the Web XP issue tracker for *"what now?"* / *"where do I start?"* decisions.

## Inputs

### Issue-tracker data

Run:

```bash
gh issue list --repo GarrettS/web-xp --state open --limit 100 --json number,title,labels,assignees,comments,state,closedAt,createdAt,updatedAt,milestone,body,url
```

Use the returned issue bodies and comment timestamps as the primary activity signal.
Do not treat `updatedAt` as substantive activity because label backfills can change it without advancing the work.

### Maintainer context

Read any short-term project signals that affect prioritization, such as:

- active milestone theme
- current labels and what they mean
- known contributor availability
- coordination constraints or release goals

If no extra maintainer context is provided, say so and continue with issue-tracker evidence only.

## Procedure

1. Read the issue list output in full.
2. Treat each issue as read-only source material. Do not mutate issues as part of this workflow.
3. Determine the assignment state for each issue:
   - **Unassigned** — open, no assignee.
   - **Assigned** — has assignee.
   - **In progress** — assigned, plus recent comment activity. Heuristic, not classification.
4. Identify orthogonal slices where they apply:
   - **Blocked** — unchecked `Blocked by` refs or unresolved `needs-design`.
   - **Regressed** — reopened work (`closedAt` non-null while state is `OPEN`, if present in the source set).
   - **Stale** — no comment activity in 30+ days.
   - **Good for newcomers** — unassigned, `help wanted`, no `good first issue`, and scoped enough to look mechanical.
5. Weigh the tracker for path-forward value:
   - **High leverage** — unassigned work that unblocks the most follow-on work or advances the next milestone.
   - **Contributor entry points** — newcomer-accessible unassigned work.
   - **Dormant ownership** — assigned work that has gone quiet and may need release or a status check.
   - **Tracker hygiene** — stale, semi-obsolete, or poorly framed issues that should be tightened or retired.
   - **Milestone fit** — work aligned with the active theme versus defer candidates.
6. Surface only actionable relationships:
   - explicit cross-references such as `#N`, `depends on`, `blocks`
   - dependency chains that matter to the next decision
   - high-overlap suggested relationships when they materially change prioritization
7. If issue text quality is distorting triage signal, recommend cleanup as a next move instead of silently rewriting the issue. For meta-mode leakage, use `tools/route-out-meta-mode-strategy.md` as the current working reference.
8. Recommend concrete next moves. Allowed recommendation types include:
   - work this next
   - communicate first
   - defer until blocker or milestone changes
   - tighten or retire before doing more
   - hand this to a newcomer instead

## Output Contract

Produce one Markdown recap with these sections, in this order:

### Maintainer Next Moves

List the one to three highest-leverage next actions.
Each item must name the issue number, the recommended move, and a short rationale.

### Contributor Entry Points

List the best newcomer-accessible issues, if any.
If none qualify, say so.

### Assignment States

Group issues under:

- **Unassigned**
- **Assigned**
- **In progress**

Only include the issues that matter for current decisions.
Do not dump the full tracker if a shorter grouped view is clearer.

### Orthogonal Slices

Summarize issues that are:

- **Blocked**
- **Regressed**
- **Stale**
- **Good for newcomers**

If a slice is empty, omit it.

### Relationship Surfacing

List only the relationships that change what should happen next.

### Uncertainties

List any missing context, ambiguous signals, or cases where a human decision is still needed.

## Constraints

- Read-only. Do not edit issues, labels, or assignments as part of triage.
- Ground recommendations in issue text, comments, labels, milestones, and assignee state.
- Do not invent dependency chains or contributor readiness.
- Prefer explicit evidence over gut feel; when inferring, say that you are inferring.
- Staleness comes from comment activity, not `updatedAt`.
- If asked to persist the recap, write the same Markdown output to `drafts/STATUS.md`.
