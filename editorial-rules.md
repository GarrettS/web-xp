# Editorial Rules (ER)

Editorial rules for doctrine and repository artifacts in Web XP.

---

## Scope

**Covered prose** — the doctrine and repository prose these rules govern:

- drafts, including prose drafted for the user to use (e.g. a suggested explanation of the code)
- issues
- issue comments
- contributor docs
- maintainer docs
- contributor agent file: `AGENTS.md`
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
- **Concise:** Omit restatement, summary lines, and this-not-that framing. Code over prose. Say more with less. 
- **Direct:** Use imperative mood and active voice. Name APIs and elements exactly. No paraphrasing.
- **Accurate:** Use terms as defined by the authorities in **Authoritative References**.
- **Code First:** Document clear and coherent code. If the code should be adjusted for clarification, do that first.
- **Sound:** Accessible Precision — balance:
  - Technical Accuracy (exactness)
  - Completeness (edge cases)
  - Human accessibility (readability and utility)
- **Laconic:** Avoid globals. Scope locally.

---

## Application (normative)

Before sharing a draft, review it against these rules and revise. Cut filler. Read, write, review, revise, repeat — and think.

On revision, when applying feedback — any correction or new information — ask whether it matches the paragraph's topic. Do not cram it into the paragraph if that would reduce cohesion or comprehensibility; find the section where it belongs and add it there, or create one if none exists.

Enforce normative rules yourself. Do not pass known violations to the reviewer for approval. Applying `must`-level rules is mechanical, like `a === b`, and needs no sign-off. Accept and auto-accept will pass mechanical violations through, so the author is the only check. Reserve the reviewer for what judgment decides: clarity, coherence, and the patterns marked Judgment.

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

Instructional Leakage (IL) is meta content about the work, written into artifacts whose job is to *be* the work, not describe it.

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

Do not conflate the file that states a rule with the artifact it governs.

> Reject: The priming applies to `AGENTS.md`.
>
> Use: The priming in `AGENTS.md` applies to issue drafts and doctrine.

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
| ecosystem | use proper terminology; this software; nothing ecological about it | 

> Reject: Source data shaped as `[{ id, ... }]`, often paired with `.find(...)`.
>
> Use: Trigger: keyed lookup over array records that contain `id`.

---

## Lives (normative)

Nothing lives. Code, files, content, and logic do not "live" anywhere.

**Pattern:** `lives` / `lives in` (or other life verbs) stating where code, a file, or content is located.

**Action:** flag; replace with one of:

- the mechanism — name what the code does and the API that does it
- an explanation — when "lives" leads into a code block or sits where the code should be explained, explain the code
- a pointer — `see [document/section]`
- a plain location verb — `is in`, `is defined in`, `the appendix covers`

> Reject: The transition code lives in `startTransition`.
>
> Use: To smooth the transition, call `startTransition`.

> Reject: The per-feature deep dives live in the appendix.
>
> Use: See the appendix for per-feature deep dives.

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

Prose uses two registers. Decide per sentence by subject and verb:

- **Normative** — instructs. Implied second-person subject, command verb: "Use `Array.isArray`", "Avoid globals". Imperative mood.
- **Descriptive** — describes the system. Third-person subject (the code, the handler, the browser), finite verb stating behavior: "The handler reads `event.target`", "The list reorders only on drop". Declarative, present tense, third person; no second person.

**Test:** subjectless base-form verb ("Use `Array.isArray`") → normative; third-person subject + finite verb ("The handler reads `event.target`") → descriptive.

Both registers use:

- active voice
- present tense
- exact technical nouns
- no first person; second person only in normative contributor instructions
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


## Quantifier Scope (normative)

Match each determiner to its claim's scope.

Claims about every member of a class take the bare plural ("Nouns name things") or a distributive universal (`each`/`every`/`any`). The singular indefinite article does not state class claims.

**Pattern:** singular determiner — emphatic (`a single`, `one`), specific (`the X`), or generic (`a`/`an`) — where the claim it modifies is universal.

**Action:** flag; rewrite as a bare plural or a distributive universal.

**Test:** if the claim is universal and "which one?" reads as a sensible question, the determiner is too specific.

> Reject: A single artifact carries both registers.
>
> Use: Documents carry both registers.


## Slop, Codeslop & Gobbledygook

Agents typically begin with a paragraph label offset by a colon where a topic sentence would go. Example: 

"Billy likes sports: he runs, plays basketball, and swims"

Avoid this pattern.

### Coherence (judgment)

Each paragraph leads with its point, then develops it. Two failures break it — subject-shifting and trailing off.

#### Subject-shifting

**Pattern:** paragraph that conflates a second subject into the point it states.

**Action:** flag; move the second subject to its own paragraph.

> Reject: `getBoundingClientRect()` returns zeros on elements with `display: none`, and the panel also caches its scroll position.
>
> Use: `getBoundingClientRect()` returns zeros on elements with `display: none`. Measure after they are shown.

#### Trailing off

**Pattern:** paragraph that continues past its point, ending on subordinate or filler material.

**Action:** flag; cut the trailing material; close on the sentence that completes the point.

> Reject: `getBoundingClientRect()` returns zeros on elements with `display: none`. This is one of several rendering quirks worth keeping in mind.
>
> Use: `getBoundingClientRect()` returns zeros on elements with `display: none`. Positions read before they are shown are stale.

### Codeslop
AI code slop is AI-generated code that borrows framework paradigms and terms (noun, verb, metaphor), and manifests in code, comments, and communications.

| Reject | Use |
|---|---|
| `routes` (events) | `handles`, `dispatches` |
| `mounts` | `appends`, `inserts` |
| `hydrate` | builds from data |
| `lifecycle` | construction; one-time init |
| `primitive` | the class (identifier + construct) |
| `domain layer` | the module; the file |
| `data model` | the class; the decorator |
| `row` (for an `<li>`) | `item` |

