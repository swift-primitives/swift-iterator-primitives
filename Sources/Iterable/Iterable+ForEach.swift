//
//  Iterable+ForEach.swift
//  swift-iterator-primitives
//
//  The non-destructive iteration terminal on the multipass attachable.
//
//  Surface: a plain `borrowing func` (not the Property fluent-accessor pattern).
//  The Property surface cannot host iteration on a production compiler — its base
//  access is a `_read` coroutine (statement-scoped), so an iterator can't be held
//  across the loop. The clean fix is the SE-0507 `borrow` accessor — validated to
//  solve this on Swift 6.4-dev / 6.5-dev, but gated out of production releases
//  (≤ 6.3.2); revisit the Property surface when it reaches a production compiler.
//  A `borrowing func` is the modern ~Escapable shape that
//  works today: the iterator is a `~Escapable` value tied to the stable borrow of
//  `self` — no closure, no coroutine, no `unsafe` — and it reaches `~Escapable`
//  iterables (cursors), which Property cannot (Property requires an Escapable Base).
//
//  Span-primitive (SE-0516): the iterator's sole element-access is the bulk
//  `next(maximumCount:) -> Swift.Span<Element>`; `forEach` drives the span loop and lends each
//  element via the borrowing addressor `span[i]` — carrying both Copyable and `~Copyable`
//  elements with no Copyable gate (the span addressor borrows, never moves out).
//

public import Cardinal_Primitives
public import Either_Primitives
public import Iterator_Chunk_Primitives

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {
    /// Calls `body` once for each element, in iteration order — the non-destructive
    /// (borrowing, multipass) iteration terminal.
    ///
    /// Because `makeIterator()` borrows `self`, `forEach` does not consume the
    /// container: it can be called repeatedly, and it is available to *every*
    /// `Iterable` (buffers, storage, cursors, `Single` / `Empty`) — not only
    /// sequences. Each element is handed to `body` by borrow over the iterator's
    /// span, so move-only and non-escaping element types are supported.
    ///
    /// `Iterator.Failure == Never` constrains this to infallible iterators; the
    /// closure carries its own typed error `E`, propagated without erasure. A
    /// fallible-iterator overload is provided separately.
    ///
    /// - Parameter body: a closure called with a borrow of each element; may throw `E`.
    /// - Throws: any error of type `E` thrown by `body`.
    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Iterator.Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                try body(span[i])
            }
        }
    }
}

// MARK: - Fallible iterators

extension Iterable where Self: ~Copyable & ~Escapable {
    /// Calls `body` once for each element of a *fallible* iterator.
    ///
    /// When `next(maximumCount:)` itself can fail (`Iterator.Failure != Never`), `forEach` has two
    /// error channels — the iterator's `Failure` and the closure's `E` — fused, unerased, into
    /// `Either<E, Iterator.Failure>`: `.left(E)` for a closure error, `.right(Failure)` for an
    /// iterator failure. For infallible iterators the `throws(E)` overload above is more
    /// specific and wins overload resolution; this overload serves the fallible case.
    ///
    /// - Parameter body: a closure called with a borrow of each element; may throw `E`.
    /// - Throws: `Either<E, Iterator.Failure>` — `.left` from `body`, `.right` from the iterator.
    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Iterator.Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return }
            for i in span.indices {
                do {
                    try body(span[i])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
