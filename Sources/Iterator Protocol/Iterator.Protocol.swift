//
//  Iterator.Protocol.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// The iterator protocol — the codec-triple agent for iteration.
    ///
    /// A type conforming to `Iterator.\`Protocol\`` produces `Element` values one at a time
    /// via the stateful `next()` method. When iteration is exhausted, `next()` returns `nil`.
    ///
    /// ## Maximum permissive shape
    ///
    /// Iteration is single-pass and self-consuming. The protocol suppresses both
    /// `Copyable` and `Escapable` on `Self`, admitting the widest range of conformers:
    /// `~Copyable` cursors with affine resource discipline, `~Escapable` views over
    /// non-escaping storage, and ordinary value-type iterators.
    ///
    /// `Element` is `~Copyable & ~Escapable` so iterators may yield move-only or
    /// non-escaping values (buffer pages, cursor views, owned tokens, …).
    ///
    /// `Failure` defaults to `Never` for infallible iterators; iterators that may fail
    /// during iteration (streaming I/O, partial parsing) carry a typed error channel.
    ///
    /// ## Relationship to Sequence
    ///
    /// Iterator is *foundation-below* Sequence. Sequence is defined in terms of Iterator
    /// (`makeIterator() -> some Iterator.\`Protocol\``); Iterator references nothing about
    /// Sequence. This package is an atomic peer of `swift-sequencer-primitives`, not
    /// nested under it.
    public protocol `Protocol`<Element, Failure>: ~Copyable, ~Escapable {
        /// The type of value this iterator yields.
        associatedtype Element: ~Copyable & ~Escapable

        /// The error type. Defaults to `Never` for infallible iterators.
        associatedtype Failure: Swift.Error = Never

        /// Advance the iterator and return the next element, or `nil` if exhausted.
        ///
        /// The returned element's lifetime is tied to the iterator (`&self`) to admit
        /// `~Escapable` element types (e.g., views into iterator-owned storage).
        ///
        /// - Returns: the next element, or `nil` to signal exhaustion.
        /// - Throws: `Failure` if iteration fails at this step.
        @_lifetime(&self)
        mutating func next() throws(Failure) -> Element?
    }
}
