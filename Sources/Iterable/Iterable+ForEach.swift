//
//  Iterable+ForEach.swift
//  swift-iterator-primitives
//
//  The non-destructive iteration terminal on the multipass attachable.
//
//  Surface: a plain `borrowing func` (not the Property fluent-accessor pattern).
//  This is now the *settled* surface, not a workaround waiting on a compiler.
//
//  History: the original reason to defer the Property surface was that SE-0507
//  `borrow` accessors were gated out of production releases (≤ 6.3.2), leaving
//  Property's base access a `_read` coroutine (statement-scoped), so an iterator
//  could not be held across the loop. That gate is gone: SE-0507
//  (`BorrowAndMutateAccessors`) is enabled by default from Swift 6.4, the release
//  floor of this package's CI. The surface decision nevertheless stands, because
//  the *binding* constraint was never the accessor kind — it is the type:
//  `Property<Tag, Base>` requires an **Escapable** `Base` (`Base: ~Copyable`, not
//  `~Copyable & ~Escapable`), while these terminals are declared on
//  `Self: ~Copyable & ~Escapable` and must reach `~Escapable` iterables (cursors).
//  Instantiating `Property` with a `~Escapable` base is a compile error on 6.4
//  ("type 'Cursor' does not conform to protocol 'Escapable'"), so the Property
//  surface would strictly narrow this API, and splitting terminals into two shapes
//  by escapability is worse than one uniform shape.
//
//  A `borrowing func` is the modern ~Escapable shape: the iterator is a
//  `~Escapable` value tied to the stable borrow of `self` — no closure, no
//  coroutine, no `unsafe` — and it reaches every `Iterable`.
//  Revisit only if `Property` (swift-property-primitives) generalises its `Base`
//  to `~Escapable` and moves `Property.Borrow.base` off its `_read` coroutine.
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
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return }
            for i in span.indices {
                do throws(E) {
                    try body(span[i])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
