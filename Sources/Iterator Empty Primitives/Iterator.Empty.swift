//
//  Iterator.Empty.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// An iterator that yields no elements.
    ///
    /// `Iterator.Empty<Element>` immediately returns `nil` from `next()`, signaling
    /// exhaustion. Useful as the identity for sequence concatenation, as a placeholder
    /// iterator, or as the iterator of empty collections.
    ///
    /// Permits `~Copyable & ~Escapable` `Element` — the empty iterator has no element
    /// storage and never produces a value, so element copyability/escapability is
    /// unconstrained.
    public struct Empty<Element: ~Copyable & ~Escapable>: Iterator.`Protocol`, ~Copyable, ~Escapable {
        public typealias Failure = Never

        @inlinable
        @_lifetime(immortal)
        public init() {}

        @inlinable
        @_lifetime(&self)
        public mutating func next() -> Element? {
            nil
        }
    }
}
