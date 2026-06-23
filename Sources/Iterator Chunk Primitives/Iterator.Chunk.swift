//
//  Iterator.Chunk.swift
//  swift-iterator-primitives
//

public import Cardinal_Primitives
public import Cardinal_Primitives_Standard_Library_Integration

extension Iterator {
    /// The concrete bulk (chunked-span) iterator over a borrowed `Swift.Span`.
    ///
    /// `Iterator.Chunk` lends successive sub-spans of up to `maximumCount` elements,
    /// advancing an internal `Cardinal` position over the borrowed storage — the bulk-tier analog
    /// of `Iteration` for the scalar tier, and the canonical `__IteratorChunkProtocol`
    /// conformer.
    ///
    /// The tier is named for its *manner* (`Chunk` — it yields elements in bounded contiguous
    /// chunks, i.e. successive sub-spans), not its *payload* (`Span`, which would shadow
    /// `Swift.Span`) and not the storage *subject* (`Contiguous` — that word belongs to the
    /// storage subject `Storage.Contiguous`), per `operation-domain-naming-and-organization.md`
    /// §7 / `[API-NAME-001b]`.
    ///
    /// (The bulk *protocol* is the top-level `__IteratorChunkProtocol`, not
    /// `Iterator.Chunk.Protocol`: a protocol cannot nest in a generic type, so it is hoisted
    /// — see `__IteratorChunkProtocol.swift`.)
    public struct Chunk<Element: ~Copyable>: ~Copyable, ~Escapable {
        @usableFromInline let span: Swift.Span<Element>
        @usableFromInline let count: Cardinal
        @usableFromInline var position: Cardinal

        /// Wrap a span for bulk iteration, starting at its beginning.
        @inlinable
        @_lifetime(copy span)
        public init(_ span: Swift.Span<Element>) {
            self.span = span
            self.count = Cardinal(UInt(bitPattern: span.count))
            self.position = .zero
        }
    }
}

// NOTE: the conformance must name `__IteratorChunkProtocol` directly — `Iterator.Chunk`
// cannot conform to its *own* member alias `Iterator.Chunk.`Protocol`` (circular
// reference). The alias is for *consumers*; the defining type uses the hoisted name here only.
extension Iterator.Chunk: __IteratorChunkProtocol where Element: ~Copyable {
    /// The error type, `Never` — iterating a borrowed span cannot fail.
    public typealias Failure = Never

    /// Lend the next sub-span of up to `maximumCount` elements; an empty span signals exhaustion.
    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) -> Swift.Span<Element> {
        let remaining = count.subtract.saturating(position)
        let take = Swift.min(maximumCount.underlying, remaining)
        guard take > .zero else { return span.extracting(first: Cardinal.zero) }
        let result = span.extracting(droppingFirst: position).extracting(first: take)
        position = position.add.saturating(take)
        return result
    }
}
