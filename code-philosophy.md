# Code Philosophy

AI-assisted XP for lean, transparent web front-end architecture.

---

## The Approach

Web XP applies Extreme Programming to web development: small commits, continuous refactoring, pair programming, tight feedback loops, and the simplest thing that could possibly work.

Here, the AI is the pair programmer, the pre-commit checks tighten feedback, and working with the web platform directly is usually the simplest thing that could possibly work. Web XP is designed and tested against web-platform code, not framework-managed abstractions. No framework is required by default, and no build pipeline needs to be untangled before the code becomes readable. This requires more discipline than the default AI-assisted workflow, but the result is more transparent and more durable. Quality is not free, but low-quality acceleration is more expensive: the time saved by loose generation is usually paid back in debugging, inconsistency, and maintenance.

Named patterns applied through continuous refactoring, small commits, each one leaving the code cleaner than the last. Every rule in this doctrine was extracted from production code, not adapted from textbook examples. The examples are drawn from real applications; the failures they address were observed, debugged, and fixed before the rule was written.

- **Work with the web platform directly.** The patterns used here — event delegation, dispatch tables, Shared Key, Active Object — work with the DOM and standard APIs rather than abstracting over them. No abstraction layer to learn, no version to upgrade, no deprecation cycle to chase. See §Libraries, Frameworks, and TypeScript for the full reasoning.
- **A living code-guidelines document as a contract.** It keeps every contributor — human or AI — honest across sessions. It is not a suggestion file. It governs.
- **Pattern literacy over code generation.** Changes are justified by named refactoring patterns from the software engineering canon: Compose Method, Extract Shared Logic, Decompose Conditional. The question is never "does it work" — it is "is this the right abstraction?"
- **The AI is a pair programmer, not a code generator.** Its output is reviewed, challenged, and corrected. "Caught you slipping" is the expected dynamic, not an exception.

## What This Produces

Code that is readable, maintainable, and resilient to change. The guidelines compound: each refactoring encodes a principle that applies to the next, across projects. The codebase gets more consistent over time instead of accumulating layers of different styles and framework idioms.

## Libraries, Frameworks, and TypeScript

This doctrine is not anti-library. It is anti-unnecessary indirection. The question is what a dependency buys you relative to its cost in abstraction, bytes, learning surface, and maintenance.

Specialized libraries such as D3, Anime.js, Three.js, and Chart.js are useful when they solve problems that are genuinely hard to address natively: data-driven SVG binding, physics-based animation, WebGL rendering, charting, and similar specialized work. They do not take over the architecture around them. Shared Key, Event Delegation, Fail-Safe, and module ownership still apply. Even here, use the smallest tool that solves the specific problem. A library built for generality often ships abstractions you do not need, and AI can now produce many narrower alternatives such as SVG path helpers, easing functions, animation loops, and data transforms as lightweight, purpose-built code.

General-purpose frameworks such as React, Vue, Angular, and Svelte were valuable responses to earlier platform constraints: weaker language ergonomics, slower DOM work, and teams that struggled to keep UI code disciplined at scale. Much of that rationale has weakened. Browsers improved, JavaScript improved, and AI-assisted development with enforced code guidelines now provides much of the speed and consistency frameworks once supplied. Frameworks are not forbidden here, but they are often redundant. Their cost is version churn, build complexity, opaque error stacks, abstraction over native DOM ownership, and less visibility into performance and memory behavior. The patterns in this doctrine are rooted in how the web platform works, so they age more slowly than framework conventions designed around older limitations.

Many framework patterns presented as essential are solutions to problems the framework itself imposed. When the framework's most celebrated patterns exist to solve the framework's own constraints, the framework is the complexity — not the solution to it.

### What React Router, useState, and useEffect replaced — and what they replaced it with

**Routing.** The web platform provides `location.hash`, `hashchange`, `history.pushState`, and `popstate`. Routing is URL parsing plus a navigation event. The rest is application dispatch, not router machinery:

```javascript
function applyHash() {
  const h = (location.hash || '').replace(/^#/, '');
  const [tab, subtab, subview] = h.split('/');

  const section = tab
    ? document.getElementById(tab + '-content')
    : null;
  if (!section || !section.classList.contains('content')) {
    activateTab('home');
    return;
  }

  activateTab(tab);
  activateSubtab(tab, subtab);
  if (subview) activateSubview(tab, subtab, subview);
}
window.addEventListener('hashchange', applyHash);
```

Routing is URL parsing plus dispatch. No router framework required.

**State management.** React's `useState` exists because functional components discard scope on every render. That is React's constraint, not the platform's. Module state persists naturally:

```javascript
// Module state — persists for the lifetime of the page.
const decoderState = { side: 'Left', region: 'IP',
  dir: 'ER' };

function updateDecoder() {
  const { side, region, dir } = decoderState;
  const equiv = getAllEquivalent(region, dir);
  updatePelvisSVG(equiv);
  renderEquivChain(side, region, dir, equiv);
}
```

No hook, no re-render, no stale closure. The state is a plain object. The update function reads it directly and writes to the DOM. For view toggling, one class on the ancestor and CSS does the rest — no state variable needed at all:

```javascript
let activeScreenClass = 'screen-config';
function showScreen(cls) {
  document.getElementById('masterquiz-content')
    .classList.replace(activeScreenClass, cls);
  activeScreenClass = cls;
}
```
```css
#masterquiz-content {
  #mq-config, #mq-quiz, #mq-results { display: none; }
  &.screen-config #mq-config,
  &.screen-quiz #mq-quiz,
  &.screen-results #mq-results { display: block; }
}
```

**Data fetching.** `useEffect` with an empty dependency array is a workaround for missing lifecycle methods. An init function does the same thing directly:

```javascript
export async function initDecoder() {
  try {
    const resp = await fetch('data/regions.json');
    if (!resp.ok) {
      showFetchError(container, 'decoder regions');
      return;
    }
    REGIONS = await resp.json();
  } catch (fetchErr) {
    showFetchError(container, 'decoder regions');
    return;
  }
  // Set up controls, render initial state.
}
```

No `useEffect`. No dependency array. No cleanup return. The function runs once, fetches data, handles errors visibly, and sets up the module. The lazy-loading system calls it the first time the user visits the tab.

TypeScript is a separate tradeoff, not the same discussion as frameworks. It adds a build step, more surface area, and type machinery that can obscure intent.

The first project built under Web XP — a production single-page application — produced zero type-related bugs, without TypeScript. Strict mode, `===` always, material-accuracy naming, Fail-Safe, AI-assisted review, and a pre-commit check that catches mechanical violations covered the failure class TypeScript catches. Projects written in TypeScript benefit from Web XP. Projects using Web XP may find TypeScript unnecessary.

## Avoid Lock-In

We like tools that serve our projects without forcing us to reshape how we do things.

This is not just a tooling preference. It is an architectural requirement. A project should be able to adopt a tool, benefit from it, and later remove it without structural damage, migration pain, or loss of code clarity. When a framework or runner becomes a shaping force inside the project, the code stops being plainly owned by the team and starts being organized around the framework's worldview.

That problem gets worse with AI tools. Every framework-specific file, helper, convention, and abstraction in the codebase biases the AI toward generating more of the same. The AI does not evaluate whether the framework is the right abstraction; it pattern-matches on what it sees and produces consistent output. This turns accumulated framework code into a gravity well: the framework shapes the code, the code shapes the context, the context shapes the AI output, and the AI output reinforces the framework. It strengthens the sunk-cost dynamic that already discourages migration.

Web XP was designed around this principle. Its core contract is canonical and adapter-agnostic. Teams can switch between agents like Claude and Codex without restructuring the project. Other agents such as Cursor, OpenCode, and Gemini can be added by deriving from `AGENT.md`. Web XP does not require a project-local `web-xp/` directory or support tree, and it does not hook application code. Its current project footprint is limited to the agent's project contract file (`CLAUDE.md` or `CODEX.md`), and its system footprint lives in the Web XP install plus agent-specific runtime paths. See `README.md` for the current footprint and removal behavior. You own your code.

Migration cost is not an abstract future concern; it is wasted time, wasted energy, and distorted code. A good tool can disappear and leave behind healthy code. A bad tool leaves behind ruins.

See `DESIGN.md` for the adapter architecture that makes this vendor-agnostic.

## The Role of Judgment

Following these rules mechanically produces cleaner code. That is valuable but incomplete.

The deeper value comes from knowing when to push back on AI output, when a rule should bend, and when clean-looking code is still the wrong abstraction. The guidelines encode judgment extracted from production failures. They do not replace the judgment needed to apply them well.

The edge is not the document. It is your ability to pair-program with an AI to make the code better.

---

## When Rules Conflict

The guidelines contain principles, rules, defaults, and heuristics. They are not all the same kind of statement, and they do not all carry the same weight.

- **Principles** govern judgment (Fail-Safe, Module Cohesion, DOM-Light). They are the reasons behind the rules.
- **Rules** are specific and testable (`===` always, no `addEventListener` in repeatable functions, all colors via custom properties). They are followed unless a principle overrides them.
- **Defaults** apply unless there is a stated reason not to ("favor source HTML," "prefer CSS over JS for state"). The word "prefer" or "avoid" signals a default.
- **Heuristics** are context-dependent guidance (extract shared logic, decompose conditional). They require judgment about when to apply.

When two rules pull in opposite directions, the more specific rule governs within its scope. When two rules of equal specificity conflict, the one closer to the user's experience wins: Fail-Safe outranks optimization, legibility outranks mechanical compliance.

Example: Extract Shared Logic says to extract duplicated structure into a parameterized function. But extraction is not justified by duplication alone — it is justified when it names an operation and makes the calling code read as a sequence of intentions. If extraction adds indirection without improving legibility at the call site, the extraction is not warranted. The principle (legible code) governs the heuristic (extract shared structure), not the other way around.

When the conflict is not resolvable by these rules, state the tension and ask. Do not silently pick a side.

## Shared Key: Why IDs Are the Architecture

The Shared Key pattern uses a unique `id` as a single-token address across every layer — DOM lookup, dispatch routing, data access. The rationale:

**Greppability.** A developer sees `cmap-edge-3` in the browser inspector, greps `cmap-edge` in the IDE, and lands exactly on the module that owns that logic. The prefix is the module.

**Direct execution path.** Event → Dispatch Table[ID] → Method → getElementById(ID). No intermediate representations.

**One token, three roles.** The ID is the DOM address (`getElementById`), the dispatch key (`DISPATCH[id]()`), and the data key (`data[id]`). All O(1), all using the same string.

**Collision control.** Module-owned prefixes make collisions visible in a single grep. If two developers both use `edge-`, the collision is obvious — not hidden behind framework-managed scoping.

Frameworks handle identity indirectly because their rendering model changes the DOM ownership boundary. This doctrine keeps the developer in direct control of DOM identity.

In the pelvis app's `anatomize.js`, the shared domain key is the anatomy token embedded in each role-specific ID:

```javascript
const RE_IMG_ID = /^anat-img-(.+)$/;
const RE_LABEL_ID = /^anat-(.+)-label$/;
const RE_HITBOX_ID = /^anat-(.+)-hitbox$/;
const RE_BTN_ID = /^anat-(.+)-btn$/;
```

For one entity such as `left-ilium`, the same meaningful token appears across related elements:

- `anat-img-left-ilium`
- `anat-left-ilium-label`
- `anat-left-ilium-hitbox`
- `anat-left-ilium-btn`

The role changes. The domain key does not. A meaningful, human-readable ID — named from the project's ubiquitous language — is the universal coordinate across JS dispatch, DOM lookup, and CSS styling. See it in the inspector, find it in the code, know what it represents. No translation layer to hide bugs.

## Good Names

Correct terminology is not cosmetic. When code, data, selectors, and documentation use the same domain terms, moving from user terminology to implementation requires no translation. That reduces debugging cost, improves grepability, and lowers the risk of model drift.

Identifiers with material accuracy — `pelvisRotationDegrees` instead of `val`, `activeDragItem` instead of `dragging`, `ABBR_TITLES` instead of `MAP`. The name describes the domain reality, not the programming artifact. If the user calls it a "concept map," the code says `conceptMap` — not `cmap`. Programmer shorthand (`mq`, `expl`, `btn`) forces a translation in the reader's head; domain abbreviations do not, because they are the language of the domain itself. A medical app uses `ADT` and `PADT` because the clinicians do. A trading app uses `WTI` and `EUR` because the traders do. A dental app uses `FMX` and `BW` because the hygienists do. These are not programmer abbreviations — they are the vocabulary of the people the software serves.

Module-scoped variables in ES modules are not globals. Even if they were, a unique name with a descriptive prefix provides a logical namespace that the human brain (and grep) can navigate effortlessly. The "fear of globals" is a framework-era anxiety that does not apply to module-scoped state with material-accuracy naming. Name it well, scope it to the module, and move on.

The grep test: if you can find a feature by searching for the same word the user uses, the naming is correct. If you have to know that the user's "concept map" is `cmap` in the code, the naming has failed. Generic frameworks reward generic naming; this doctrine prefers custom-fit domain naming that makes the code an explicit map of the system it models.

## The CSS Engine as a State Machine

The browser's CSS engine is a declarative partner to the JS logic, not just a painting tool.

**Zero-iteration styling.** The Ancestor Class pattern — one state class on a common ancestor, descendant rules in CSS — offloads state-based visual changes to the browser's C++ style-recalc pass. No JS loops toggling classes on descendants. Example: `#equivalence-content.showing-results .equiv-quiz-wrap` — the ancestor gets the class, the cascade hides/shows the descendants.

**Predictable collision guard.** A collision in CSS is a violation of the Module Ownership contract. If two modules' styles conflict, it means they didn't grep for the prefix before implementation. The same contract that prevents ID collisions in JS prevents selector collisions in CSS.

## Defaults and Exceptions

The guidelines use "avoid," "prefer," and "where possible" to signal defaults. A default is not a suggestion — it is the expected behavior in the common case. Taking an exception requires a stated reason.

Valid reasons for exceptions:
- The alternative violates a higher-priority rule.
- The platform or browser imposes a constraint that makes the default inapplicable.
- The specific context has been discussed and an exception approved.

Invalid reasons:
- "It felt right."
- "It was easier."
- "The other approach also works."

When taking an exception, comment the code stating which default is overridden and why. This prevents a future reader from "fixing" the code back to the default and breaking the design.

## Adopting the Doctrine

The doctrine is the governing standard in `code-guidelines.md` — principles, patterns, language rules, formatting, and comments policy. It is not project-specific. Individual projects overlay their own decisions on top.

The doctrine applies to any browser application built directly on the web platform. The examples in `code-guidelines.md` are drawn from real projects (anatomy tools, quiz systems, interactive maps). They illustrate the rules; they are not requirements. A dental scheduling app, a commodity trading dashboard, and a medical reference tool all follow the same Fail-Safe, Shared Key, and Event Delegation rules — with different domain vocabulary, different data shapes, and different UI concerns.

**Project overlays** handle decisions that vary by project:
- Directory names and structure (app/dev separation is doctrine; specific directory names are overlay)
- Asset management strategy (service worker precache, build tool manifests, or neither)
- Typography (system font stacks are the default; brand typefaces are an overlay decision)
- Minimum target viewport width (320px is typical; the project spec may set a different floor)
- Theming (light/dark is doctrine when theming is needed; whether theming is needed is a project decision)
- Color system (CSS custom properties for all colors is a strong default; a two-color utility app may not need the indirection)

A project overlay is a separate file — not a fork of the doctrine. For example, the [PRI Pelvis Restoration study tool](https://github.com/GarrettS/pelvis) uses `prd/project.md` as its overlay — content authority, directory structure, asset rules, and key architecture decisions all live there, separate from the doctrine itself.

The doctrine evolves; overlays track project-specific decisions that the doctrine intentionally leaves open. When the overlay contradicts the doctrine, the overlay must state which rule it overrides and why, per §Defaults and Exceptions.
