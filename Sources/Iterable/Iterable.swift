//
//  Iterable.swift
//  swift-iterator-primitives
//
//  The Iterable attachable — capability attachment for the iterator codec-triple.
//

public import Iterator_Chunk_Primitives

/// A type that has a canonical iterator.
///
/// `Iterable` is the codec-triple's attachable for iteration: conformers declare a
/// canonical way to iterate themselves via `makeIterator()`. Types opt in to expose
/// iteration without themselves being iterators.
///
/// ## The multipass attachable — one of two orthogonal siblings
///
/// `Iterable` is the *multipass* attachable: `makeIterator()` is `borrowing`, so the
/// container survives the call and can be re-iterated. Its sibling `Sequenceable` (the
/// single-pass attachable in `swift-sequencer-primitives`, when it lands) is *consuming* —
/// it hands its elements away once, which is what admits one-shot sources and lazy
/// pipelines.
///
/// These are **orthogonal capabilities, not a refinement chain.** For a `~Copyable`
/// element the borrow-vs-consume choice is forced: you cannot both keep a container
/// re-readable (multipass) *and* move its owned elements out (give-away). So
/// multipass-borrowing and single-pass-consuming are distinct — the same orthogonality
/// that separates `Collection` from `Sequence`. Both attachables vend an
/// `Iterator.`Protocol``, and there is no refinement edge making a `Sequenceable`
/// automatically `Iterable`. A single type *can* conform to both, but not for free:
/// both protocols declare `associatedtype Iterator`, which Swift unifies across
/// protocols, so a dual conformer splits the two bindings with
/// `@_implements(Protocol, Iterator)` at that type (a local cost — the
/// associated-type-trap escape hatch).
public protocol Iterable: ~Copyable, ~Escapable {
    /// The iterator type this instance produces — the **span-primitive** bulk iterator
    /// (`__IteratorChunkProtocol`, the SE-0516 `BorrowingIteratorProtocol` analog), NOT the scalar
    /// `Iterator.`Protocol``. Its sole element-access primitive is
    /// `next(maximumCount:) -> Swift.Span<Element>`; because `Swift.Span<Element: ~Copyable>`'s subscript is a
    /// borrowing addressor, one iterator serves **both** element kinds (`span[i]` borrows, never
    /// moves out) — which dissolves the move-out wall that previously forced a scalar primitive.
    ///
    /// Suppresses `Copyable` & `Escapable` so move-only / non-escaping cursors can be vended; without
    /// the suppression the associated type would silently require a `Copyable & Escapable` iterator
    /// and reject every move-only iterator in the family.
    associatedtype Iterator: __IteratorChunkProtocol, ~Copyable, ~Escapable

    /// Construct a fresh iterator over this value.
    ///
    /// `@_lifetime(borrow self)`: the vended iterator borrows the container and so may not outlive
    /// it. Because the iterator may be `~Escapable` (per the suppression above), a lifetime
    /// relationship is required, and `borrow self` is the only one that holds for *every* conformer
    /// — `copy self` is rejected when `self` is `Escapable`, which is the common case (an escapable
    /// container such as `Single<Int>`). The contract is the natural one for owned iteration: you
    /// iterate a container while you are holding it.
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator
}
