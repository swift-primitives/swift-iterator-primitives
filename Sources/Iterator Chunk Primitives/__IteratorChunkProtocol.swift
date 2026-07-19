//
//  __IteratorChunkProtocol.swift
//  swift-iterator-primitives
//
//  Hoisted bulk (chunked-span) iterator protocol.
//
//  `Iterator.Chunk<Element>` is a concrete *generic* conformer (the span-backed bulk
//  iterator), and a protocol cannot be nested in a generic context — that is a hard
//  compiler error (`protocol 'Protocol' cannot be nested in a generic context`), per the
//  tier-3 DECISION `swift-institute/Research/nested-protocols-in-generic-types.md`. So the
//  protocol is hoisted to a top-level `__`-name (the stdlib-style "workaround D2"). Consumers
//  reference `Iterator.Chunk.`Protocol`` (the nested alias); `Iterator.Chunk` is
//  its canonical concrete iterator.
//
//  This tier is named for its *manner* (`Chunk` — it yields elements in bounded contiguous
//  chunks, i.e. successive sub-spans), not its *payload* (`Span`, which would shadow
//  `Swift.Span`) and not the storage *subject* (`Contiguous` — that word belongs to the storage
//  subject `Storage.Contiguous`), per `operation-domain-naming-and-organization.md` §7 /
//  `[API-NAME-001b]`.
//

public import Cardinal_Primitives

/// A bulk iterator: yields a borrowed `Span` of elements per step, not one at a time.
///
/// **Span-primitive** (the SE-0516 `BorrowingIteratorProtocol` analog): `next(maximumCount:)` is
/// the *sole* element-access primitive — there is no scalar move-out `next() -> Element?`. Because
/// `Swift.Span<Element: ~Copyable>` exists and `Span`'s subscript is a *borrowing addressor* (`span[i]`
/// borrows, never moves out), one bulk iterator serves **both** element kinds.
///
/// The element bound is `~Copyable`, NOT the over-narrow `Escapable`: `Span` admits `~Copyable`
/// elements and only excludes `~Escapable` ones, so `~Copyable` is the correct ceiling (the earlier
/// `Escapable` bound conflated `~Copyable` with `~Escapable`).
///
/// Does **not** refine the scalar `Iterator.`Protocol`` — a `~Copyable` chunk iterator must not owe
/// the scalar move-out `next() -> Element?` (the move-out wall the span primitive removes). It
/// declares its own `Element` / `Failure` primary associated types (previously inherited from the
/// now-dropped refinement), mirroring stdlib `BorrowingIteratorProtocol`.
///
/// The count parameter is any cardinal carrier (`some Carrier.`Protocol`<Cardinal>`),
/// matching the ecosystem's count-parameter idiom.
public protocol __IteratorChunkProtocol<Element, Failure>: ~Copyable, ~Escapable {
    /// The element kind this iterator lends.
    ///
    /// `~Copyable` (not `~Escapable` — `Span` excludes it).
    associatedtype Element: ~Copyable

    /// The error type.
    ///
    /// Defaults to `Never` for infallible iterators.
    associatedtype Failure: Swift.Error = Never

    /// Advance and return up to `maximumCount` elements as a borrowed span.
    ///
    /// The span borrows the iterator (`@_lifetime(&self)`). An empty span signals exhaustion.
    ///
    /// - Parameter maximumCount: the maximum number of elements to yield this step.
    /// - Returns: a span of at most `maximumCount` elements; empty signals exhaustion.
    /// - Throws: a `Failure` if the underlying source fails.
    @_lifetime(&self)
    mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Swift.Span<Element>

    /// Skip up to `maximumOffset` elements; returns the number actually skipped (SE-0516 `skip(by:)`).
    ///
    /// A default implementation drives `next(maximumCount:)`.
    mutating func skip(by maximumOffset: Int) throws(Failure) -> Int
}

extension __IteratorChunkProtocol where Self: ~Copyable & ~Escapable {
    /// Default `skip(by:)` — drives `next(maximumCount:)` until `maximumOffset` elements are
    /// consumed or the iterator is exhausted (models stdlib `BorrowingSequence.swift:86-96`).
    @inlinable
    public mutating func skip(by maximumOffset: Int) throws(Failure) -> Int {
        var remainder = maximumOffset
        while remainder > 0 {
            let span = try next(maximumCount: Cardinal(UInt(remainder)))
            if span.isEmpty { break }
            remainder &-= span.count
        }
        return maximumOffset &- remainder
    }
}
