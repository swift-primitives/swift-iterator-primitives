//
//  Iterator.Repeating.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// An iterator that yields the same element forever.
    ///
    /// `Element` must be `Copyable` because the iterator returns it on every call to
    /// `next()`. For move-only elements that should be yielded once, use
    /// `Iterator.Once<Element>` instead.
    public struct Repeating<Element>: Iterator.`Protocol` {
        public typealias Failure = Never

        @usableFromInline
        internal let element: Element

        @inlinable
        public init(_ element: Element) {
            self.element = element
        }

        @inlinable
        public mutating func next() -> Element? {
            element
        }
    }
}
