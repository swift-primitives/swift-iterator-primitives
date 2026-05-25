//
//  Iterator.Once.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// An iterator that yields exactly one element, then is exhausted.
    ///
    /// `Element` must be `Copyable` for v0. The `~Copyable` Element variant requires
    /// noncopyable enum-state-machine support that's still rough in current Swift; once
    /// the language stabilizes that pattern, this type can be widened.
    public struct Once<Element>: Iterator.`Protocol` {
        public typealias Failure = Never

        @usableFromInline
        internal var element: Element?

        @inlinable
        public init(_ element: Element) {
            self.element = element
        }

        @inlinable
        public mutating func next() -> Element? {
            defer { element = nil }
            return element
        }
    }
}
