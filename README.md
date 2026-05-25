# swift-iterator-primitives

Single-pass iteration as a Swift Institute codec-triple application — `Iterator.\`Protocol\`` for the agent, `Iterate<Element, Failure>` for the type-erased witness, `Iterable` for the capability attachment.

## The codec-triple application

| Role | Identifier | Purpose |
|---|---|---|
| Agent namespace + protocol | `enum Iterator` + `Iterator.\`Protocol\`<Element, Failure>` | "Acts as an iterator." Stateful single-pass cursor with typed throws. |
| Witness | `Iterate<Element, Failure>` | Top-level closure-backed type-erased iterator value. |
| Attachable | `Iterable` | A type that vends a canonical iterator via `makeIterator()`. |
| Concrete iterators | `Iterator.Empty`, `Iterator.Once`, `Iterator.Repeating` | Standard building blocks. |

## Witness naming — method-stem divergence

The witness is named `Iterate` (verb form of the agent name `Iterator`), not `Next` (the protocol's method name). This is the codec-triple's documented exception for agents whose method name doesn't share a stem with the agent name. See `agent-witness-attachable-pattern.md` §3.

## Architectural placement — foundation, not nested

`swift-iterator-primitives` is an **atomic peer package** to (the future) `swift-sequencer-primitives`, not nested under it. Sequence is defined in terms of Iterator (`makeIterator() -> Iterator`); Iterator references nothing about Sequence. The dependency is strict and one-way: Sequence → Iterator. Nesting iterator under sequencer would invert the real conceptual direction.

See pattern doc §12.8 case 5 for the principle: when a noun-namespace's contents form a coherent foundation-layer concept that a derived agent depends on, the foundation gets its own package, not nested membership.

## Maximum `~Copyable` / `~Escapable` support

The protocol admits maximally permissive conformers:

- `Iterator.\`Protocol\``: `~Copyable, ~Escapable` Self
- `Element`: `~Copyable & ~Escapable`
- `next()`: returns `Element?` with `@_lifetime(&self)` to admit `~Escapable` elements

`Iterator.Empty<Element>` is the most permissive concrete iterator (no element storage; both `~Copyable, ~Escapable`).

The `Iterate<Element, Failure>` witness is closure-backed and therefore limited to Copyable + Escapable `Element` (current Swift closure-capture limitation). Iterators yielding move-only or non-escaping elements should conform to `Iterator.\`Protocol\`` directly rather than going through `Iterate`.

`Iterator.Once<Element>` and `Iterator.Repeating<Element>` are Copyable-element types for v0; widening Once to `~Copyable & ~Escapable` Element awaits stabilization of Swift's noncopyable enum-state-machine patterns.

## Getting started

```swift
.package(path: "../swift-iterator-primitives")
```

Then in a target's dependencies:

```swift
.product(name: "Iterator Primitives", package: "swift-iterator-primitives")
```

Or import specific sub-targets:

```swift
import Iterator_Protocol  // just the protocol
import Iterate            // the witness
import Iterator_Empty_Primitives  // just the Empty concrete iterator
```

## License

Apache 2.0.
