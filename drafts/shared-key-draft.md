## Shared Key

### Governing Statement

Use one string _key_ across associated lookups in data, DOM, and behavior.

### Rule

When code associates an object property and a DOM element, give them a shared meaningful key, typically `id`. The same string key can address data (`data[id]`), get an element (`document.getElementById(id)`), and route actions (`CLICK_DISPATCH[id]`). One key supports multiple direct lookups and [minimizes traversal](#minimize-traversal-scope).

### Terms

- **Shared Key** - the Web XP Pattern.
- **key** - unique semantic key that names the entity or relationship.
- **key slot** - the element-owned property or data-owned place where the key belongs.
- **direct access** - addressing data, DOM, dispatch, relationship maps, or behavior by key instead of scanning.

### Legitimate Iteration

Iteration is justified for rendering, ordering, filtering, or transforming collections, not to recover one already-known entity by key.

### Known Key

For objects with unique identifiers (SKU, CUSIP, VIN, or any other UID), use the identifier as the key.

In JSON, object property names should serve as unique keys when keyed lookup is wanted.

Use `{ [key]: object }`, not `[ { id: key, ... } ]`. Searching an array for a matching `id` is O(n), which defeats
Shared Key.
  
**Code Smell**

The code scans a list to recover an object whose identifier is already known.

```js
const question = QUESTIONS.find(question => question.id === questionId);
```

**Finding**

Lookup for a specific thing implemented as repeated search instead of direct access by string key.

**Trigger**

```text
.find(...) comparing an object identifier to a known identifier, or
querySelector('[data-id="..."]') / [attr="..."] selectors recovering an entity by a known key
```

**Resolution**

Do not repeat `.find(...)` if the data have identifiers. Get them as an object keyed by identifier (ask backend, if needed). If that cannot happen, such as with siloed backend/frontend ownership, transform the list once, ideally on demand.

**Preferred Shape**

```js
const question = QUESTIONS[questionId];
```

If you cannot change the data, convert it to a keyed object for repeated O(1) lookups:

```js
const QUESTIONS_BY_ID = Object.fromEntries(
  QUESTIONS.map((question) => [question.id, question])
);
```

**Investigation**

- Are you looking for a specific thing?
- What uniquely identifies it?
- How can that identifying criteria be represented as a string key?
- Can that key be carried instead of recovered by search?
- Can the data source provide an object keyed by that string?

### Relationship Scan, Composite Key

**Code Smell**

The code knows the endpoint keys but scans a relationship list to find that relationship.

```js
const link = links.find((link) =>
  link.from === fromId && link.to === toId);
```

**Trigger**

```text
.find(...) comparing from/to endpoint keys
```

**Finding**

Lookup for a specific relationship is implemented as repeated search instead of direct access by string key.

**Resolution**

Use a composite key. If endpoint order should not matter, canonicalize it before lookup.

**Preferred Shape**

```js
const link = linksByPair[canonicalPairKey(fromId, toId)];
```

**Investigation**

- Are you looking for a specific relationship between two things?
- What uniquely identifies that relationship?
- Can that relationship be represented as a string key?
- Should endpoint order change the key?

### Key Slots

Choose the carrier and the place on that carrier that fit the key. On the DOM side: the element and its property or attribute. On the data side: the object property key in keyed data.

Use elements and attributes that fit the context. Do not shoehorn keys into `id`. A button's `value` may carry a key more directly than an `id` suffix.

Use meaningful identifier tokens in element ids. For associated elements, use the same token with a suffix for each one's role so each id is unique, addressable, and identifiable to humans.

For JavaScript objects, the key slot is the object property key.

Put the key in an Element slot that fits semantically. If other modules will use it, make it convenient.

### Element Key Slots

- `id` when the DOM element itself needs stable identity.
- `value` when a form-associated control carries the key for what it represents or acts on.
- `<data value>` when visible content has a machine-readable entity key.
- `name` when a form field contributes the payload key.
- `data-*` when no more specific key slot fits.

### Forced Key

**Code Smell**

A key is fabricated to fit a slot, or stored in a slot whose semantics don't match the element's role.

```html
<button type="button" id="mq-result-save-q42">Save as Flashcard</button>
```

```js
saveCard(button.id.replace('mq-result-save-', ''));
```

**Trigger**

`.id.replace(` or templated id `` `<prefix>-${key}` `` paired with dispatch routing on the prefix.

**Investigation**

- Where does the key belong — `id`, `value`, `<data value>`, `name`, or `data-*`?
- What is the element's role (DOM identity, form control, label, data carrier, payload)?

**Finding**

Either or both:

- The key is stored in a slot that does not suit the element and the key.
- The key is contrived just to force `id` through the DOM.

**Resolution**

Choose the element and key slot (property or attribute) whose meaning suits the key. Do not force the key into the wrong place just to move it through the DOM.

```html
<button type="button" value="q42">Save as Flashcard</button>
```

```js
saveCard(button.value);
```

### Misplaced Key

**Code Smell**

Collection is represented as an array of objects, each with its key as a property (such as id). Retrieval by that key requires an O(n) scan.

```
  "causalChains": [
    { "id": "diaphragm-to-adt", "title": "...", "steps": [...] },
    { "id": "outlet-to-padt", "title": "...", "steps": [...] }                            
  ]                                                                                       
```

**Trigger**

Source data shaped as `[{ id, ... }]`, often paired with `.find(item => item.id === key)` at consumer sites.

**Investigation**

- Is the collection accessed by key, by order, or both?
- Is the data shape under app control, or externally supplied?
- Does any consumer rely on iteration order, or only on keyed lookup?

**Finding**

The collection has app-owned keys but is shaped as an array, forcing O(n) scans for keyed access.

**Resolution**

Represent the collection as an object keyed by identifier; `{ [id]: ... }`, not `[ { id: ... } ]`.

**Preferred Shape**

```
  "causalChains": {                                                                       
    "diaphragm-to-adt": { "title": "...", "steps": [...] },
    "outlet-to-padt":   { "title": "...", "steps": [...] }
  }                                                                                       
```

### Array Position Instead of Key

**Code Smell**

DOM ids derived from array position.

```js
chainState[ci]
el.id = `chain-${ci}`;
```
*HTML*

```html
<ul id="chain-2"></ul>
```

**Trigger**

`state[index]` paired with DOM IDs using the same index.

**Investigation**

- Is the element `id` derived from array position?
- What's the data access pattern? If the answer is "by position" or "in order", array is right and id is not needed.

**Finding**

The app key is present in the data, but state and DOM are addressed by array index instead.

**Explanation**

`ci` is array position; `id` is the app key, already in the data. The problem was using a positional stand-in for identity when the app key existed. The fix was to use the app key as the single identity across data, state, and DOM. The solution also added a Decorator with an `id` getter inside a Decorator Factory.

**Resolution**

Use the app key as the single identity. Use array position only for order.

**Preferred Shape**

```js
chainState[chain.id]
el.id = chain.id;
```
*HTML*

```html
<ul id="causal-chain-respiration"></ul>
```

**Boundary**

If the data are still `[ { id, ... } ]`, this may also be Misplaced Key.


## Related Rules / Related Sections

- **Minimize Traversal Scope** - when the key is known, address the target directly.
- **Event Delegation** - delegated events often provide the element whose key slot resolves the key.
- **Ubiquitous Language** - keys use app/domain language, not generated or positional handles.
- **Dispatch Table** - action routing can use the same key for direct dispatch.
- **Decorator** / **Decorator Factory** - consumes Shared Key when creating or retrieving one behavior object per keyed Element/UI object.
- **Active Object** - may hold the currently active keyed element or object directly.
- **Encapsulation** - limits what crosses the Shared Key contract.
