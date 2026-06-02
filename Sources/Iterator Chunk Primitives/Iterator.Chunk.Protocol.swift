//
//  Iterator.Chunk.Protocol.swift
//  swift-iterator-primitives
//

extension Iterator.Chunk {
    /// The nice-spelling alias for the bulk-iterator protocol.
    ///
    /// The protocol itself is the top-level `__IteratorChunkProtocol` (it cannot nest in this
    /// generic type — see `__IteratorChunkProtocol.swift`); this alias restores the
    /// `Iterator.Chunk.\`Protocol\`` spelling so consumers rarely need the `__`-name.
    public typealias `Protocol` = __IteratorChunkProtocol
}

extension Iterator.Chunk.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns the next single element, or `nil` at exhaustion.
    ///
    /// Derived from bulk `next(maximumCount:)` — a bulk iterator satisfies the single-element
    /// foundation for free. Requesting `maximumCount: .one` keeps it lossless. Available only for
    /// `Copyable` elements: the element is copied out of the borrowed span, so the result carries
    /// no lifetime dependence on the iterator.
    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        let span = try next(maximumCount: Cardinal.one)
        return span.isEmpty ? nil : span[0]
    }
}
