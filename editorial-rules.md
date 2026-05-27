# Editorial Rules

Editorial rules for doctrine and repository artifacts in Web XP.

---

## Scope

Doctrine and repository artifacts:

- drafts
- issues
- issue comments
- contributor docs
- maintainer docs
- contributor agent files:
  - `CLAUDE.md`
  - `CODEX.md`
  - `AGENTS.md`
- Architectural Design docs
- PRDs

---

## Classification (normative)

1. **Normative:** Mechanical rules. Apply the rule's stated action.
2. **Judgment:** Context-dependent patterns. Flag pattern, propose fix, defer to human.

Each rule below states:

- the pattern (what to detect)
- the action (what to do when detected)

---

## Principles

- **Technical Standard:** Every word performs a function. Maximize information per syllable.
- **Concise:** Omit restatement, summary lines, and negative constraints. Code over prose.
- **Direct:** Use imperative mood and active voice. Name APIs and elements exactly. No paraphrasing.
- **Accurate:** Use terms as defined by the authorities in **Authoritative References**.
- **Sound:** Accessible Precision — balance:
  - Technical Accuracy (exactness)
  - Completeness (edge cases)
  - Human accessibility (readability and utility)
- **Laconic:** Avoid globals. Scope locally.

---

## Format (normative)

Each rule section pairs a Reject example with a Use example inside a blockquote.

---

## Authoritative References (normative)

When about to use a web-platform term, consult the spec that defines it:

- **Web platform:** WHATWG specs (HTML, DOM, URL, Fetch)
- **JavaScript:** ECMA-262
- **CSS:** W3C CSS specs
- **General reference:** MDN

**Pattern:** invented or imprecise terminology where a spec term exists.

**Action:** flag; replace with the spec-defined term.

> Reject: A `<details>` is an HTML expandable.
>
> Use: A `<details>` is a disclosure widget (WHATWG HTML, "The details element").

Where authorities conflict, name the choice and the reason in the relevant rule section.

---

## Sound (judgment)

**Pattern:** verdict without mechanism.

**Action:** flag; reword to name the mechanism.

> Reject: `instanceof` is unreliable.
>
> Use: `instanceof` tests prototype-chain identity against a same-realm constructor. Values from another realm (iframe, worker, `vm`) fail the check.

---

## Instructional Leakage (judgment)

Instructional Leakage is meta content about the work, written into an artifact whose job is to *be* the work, not describe it.

**Categories** include but are not limited to:

- instructions
- revisions
- compliance
- process
- critique

**Sources** include but are not limited to:

- prompts
- agent planning / impromptu ideation
- handoff files (notes from other agents)
- progress notes
- reviews
- prior draft revision
- discussion about the subject
- persistent agent memory
- tool output

**Artifacts** include but are not limited to:

- drafts
- issues
- issue comments
- doctrine
- contributor docs
- maintainer docs
- agent instructions
- Architectural Design docs
- PRDs

**Action:** flag the leakage; delete it from the artifact (the artifact is the work, not commentary about it).

> Reject: This issue clarifies the broader framing around how doctrine should be shaped.
>
> Use: Doctrine text must state the rule boundary, violation trigger, and corrected form.

### Self-References

Reject self-references unless used in dependency notes:

- "this issue"
- "the issue scope"
- "this issue ships"

### Scope Defenses

Reject phrases that defend scope by negation:

- "not narrowed to X"
- "not just Y"
- "the broader Z"

State what the artifact covers, not what it does not cover. Omit out-of-scope lists unless needed to disambiguate a known boundary.

### Revision Narration

Reject sentences that narrate the revision:

- "The point of this is..."
- "What this demonstrates..."

If the artifact is accurate, the point is evident.

### Meta-ACs

Omit acceptance criteria that describe prose formatting instead of delivery.

> Reject: The issue must have three bullets.
>
> Use: `editorial-rules.md` contains examples for:
>
> - instructional leakage
> - exact technical nouns
> - requirement words
> - empty intensifiers

### Rule Location vs. Governed Artifact

Do not conflate the file where a rule lives with the artifact it governs.

> Reject: The priming applies to `CODEX.md`.
>
> Use: The priming in `CODEX.md` applies to issue drafts and doctrine.

### Section Restatement

Reference sections by name. Do not paraphrase or duplicate their content.

---

## Exact Technical Nouns (normative)

**Pattern:** overloaded noun used in place of a concrete noun.

**Action:** flag; replace with the concrete noun from the table.

| Reject | Use |
|---|---|
| data shape | object layout, array form, schema |
| return shape | return type |
| repeated shape | DOM subtree, template node |
| review shape | review sequence |
| surface | file, API, DOM, command, UI, adapter path |
| seam | module boundary, API boundary, extraction point |
| framing | rule boundary, issue scope, claim |

> Reject: Source data shaped as `[{ id, ... }]`, often paired with `.find(...)`.
>
> Use: Trigger: keyed lookup over array records that contain `id`.

---

## Requirement Words (normative)

Use lowercase modals only for these functions:

| Modal | Function |
|---|---|
| `must` / `must not` | Binding rule / prohibited behavior |
| `should` / `should not` | Default with stated exceptions / discouraged default |
| `may` / `can` | Permission / capability |

RFC 2119 ALL-CAPS forms (MUST, SHOULD, MAY) are reserved for tight agent operations per `MAINTAINERS.md:82`. Doctrine prose uses lowercase.

**Pattern:** modal or frequency word that hides a condition.

**Action:** flag; replace with the named condition or mechanism.

> Reject: This can cause bugs.
>
> Use: This duplicates state and permits stale reads.

> Reject: Semantic markup usually reduces DOM size.
>
> Use: Semantic markup removes JS state and manual synchronization.

> Reject: You should try to avoid globals.
>
> Use: Avoid globals. Scope locally.

---

## Quality Words (judgment)

**Pattern:** quality claim that lacks a test.

**Action:** flag; replace with one of:

- a constraint
- a condition
- a test
- a failure mode
- a code example
- an exact technical noun

| Reject | Use |
|---|---|
| meaningful, robust | identifier from app domain; check success, failure, malformed |
| clear, useful | name the failed operation; show violation and corrected form |
| powerful, elegant | state technical property or mechanism |
| clean setup | setup that removes stale generated files before copying |
| material accuracy | domain-accurate naming |
| materially accurate | named with domain terms |
| narrower, broader, simpler, cleaner, stricter, tighter | name the axis and the property tested |
| single source of truth | name the variable, its writer, and its readers |

> Reject: `instanceof` is narrower.
>
> Use: `instanceof` tests realm-local constructor identity, not exposed properties.

---

## Rhetorical Metaphor (judgment)

**Pattern:** metaphor in rules, acceptance criteria, or agent instructions.

**Action:** flag; reword as the literal mechanism.

> Reject: The framework becomes a shaping force.
>
> Use: Framework files bias agent output toward:
>
> - framework APIs
> - lifecycle hooks
> - directory layout
> - state conventions

> Reject: Doctrine changes ripple.
>
> Use: After a doctrine edit, check:
>
> - linked skills
> - contracts
> - pre-commit checks

> Reject: The issue framing is wrong.
>
> Use: The issue does not state a testable rule boundary.

---

## Empty Intensifiers (normative)

Empty intensifiers add emphasis without information.

- `actually`
- `basically`
- `clearly`
- `easy`
- `essentially`
- `fundamentally`
- `genuinely`
- `just`
- `obviously`
- `of course`
- `real`
- `really`
- `simply`

**Action:**

1. Flag each occurrence.
2. Review context. Keep if the word is:
   - quoted as source text, or
   - part of a technical term or proper noun (e.g., "Real User Monitoring", "real number").
3. Otherwise, delete.

> Reject: Use the realm-safe replacement where the constructor genuinely is the question.
>
> Use: Use realm-safe checks for built-in types — e.g., `Array.isArray`, `Number.isFinite`, `err.name === "TypeError"`.

> Reject: Simply call `getElementById`.
>
> Use: Call `getElementById`.

---

## Prose Mechanics (normative)

Doctrine and rule prose uses:

- imperative mood
- active voice
- present tense for runtime behavior
- no first person; second person only in contributor instructions
- punctuation outside quotation marks unless part of the literal string (Web XP follows WHATWG, Wikipedia, and Linux-kernel style here, departing from the Google Developer Documentation Style Guide)

**Pattern:** prose that violates any of the above.

**Action:** flag; rewrite to conform.

> Reject: One should use `Array.isArray`.
>
> Use: Use `Array.isArray`.

> Reject: `event.target` is read.
>
> Use: The handler reads `event.target`.

> Reject: The browser will cache the response.
>
> Use: The browser caches the response.

> Reject: We should avoid globals.
>
> Use: Avoid globals.

> Reject: Set the role to "button."
>
> Use: Set the role to "button".
