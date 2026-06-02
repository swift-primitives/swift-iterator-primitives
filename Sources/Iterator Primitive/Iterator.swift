//
//  Iterator.swift
//  swift-iterator-primitives
//
//  The Iterator namespace — agent of the codec-triple applied to iteration.
//

/// Namespace for iterator-domain types.
///
/// `Iterator` is the agent namespace of the codec-triple applied to iteration. It hosts
/// `Iterator.\`Protocol\`` (the agent protocol), the `Iterator.repeating(_:)` factory, and
/// `Iterator.Once` — the one-element owned iterator nested here because it is iterator-specific.
///
/// `Iterator.Once<Element>` owns its element and yields it once. It is **nested under this
/// namespace** (unlike the cross-domain bare types) because it is purely iterator-domain: there
/// is no multipass or sequence framing for an owned one-shot source.
///
/// The *cross-domain bare* types live at **top level**, not nested here. `Empty<Element>` is the
/// zero-element type; its bare type lives in `swift-empty-primitives` and its iterator conformance
/// in `swift-empty-iterator-primitives` (neither re-exported here) because `Empty` is the shared
/// zero-element conformer across the whole iteration family
/// (iterator, and — on reconciliation — sequence/collection), and a type shared across domains
/// cannot nest under any one of them (cf. stdlib `EmptyCollection`). The one-element *container*
/// `Single` (`swift-single-primitives`) is the keep-and-lend counterpart to `Iterator.Once`: it
/// stores its element for multipass borrowing access and vends `Iterator.Once` via
/// `swift-single-iterator-primitives`.
///
/// The type-erased witness is the nested `Iterator.Witness<Element, Failure>` per
/// `[PKG-NAME-015]` / `operation-domain-naming-and-organization.md` §5, with the result-noun
/// alias `typealias Iteration = Iterator.Witness` exported at module scope (the value you
/// *hold*). The active capability protocol `Iterator.\`Protocol\`` carries the gerund alias
/// `Iterating` (the capability you *conform to*).
///
/// The attachable `Iterable` lives at top level.
public enum Iterator {}
