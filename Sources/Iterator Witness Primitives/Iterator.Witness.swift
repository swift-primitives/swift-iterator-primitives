//
//  Iterator.Witness.swift
//  swift-iterator-primitives
//
//  The closure-backed iterator witness — nested `Namespace.Witness` form.
//

extension Iterator {
    /// The type-erased iterator witness.
    ///
    /// `Iterator.Witness<Element, Failure>` is a closure-backed implementation of
    /// `Iterator.\`Protocol\``, suitable for wrapping any conforming iterator behind a single
    /// nominal type or for constructing iterators directly from a `next()`-shaped closure.
    ///
    /// ## Witness naming — `Namespace.Witness` + result-noun alias
    ///
    /// Per `operation-domain-naming-and-organization.md` §5 / `[PKG-NAME-015]`, the canonical
    /// type-erased witness of an operation domain is nested as `Namespace.Witness`. The result-noun
    /// `Iteration` is preserved as the top-level alias `typealias Iteration = Iterator.Witness`
    /// (`[PKG-NAME-015]` gates: deverbal result-noun ✓, first-class English noun ✓, free in the
    /// ecosystem ✓, sole alias ✓; exempt from `[API-NAME-004a]` per the witness-alias exemption).
    /// The gerund `Iterating = Iterator.\`Protocol\`` names the capability you *conform to*; the
    /// result-noun `Iteration` names the value you *hold*.
    ///
    /// ## Copyable-element limitation
    ///
    /// Closure-backed storage limits `Element` to types that Swift's closure-capture
    /// machinery accepts. Iterators yielding move-only or non-escaping elements should
    /// conform to `Iterator.\`Protocol\`` directly rather than using `Iterator.Witness`.
    public struct Witness<Element, Failure: Swift.Error>: Iterator.`Protocol`, ~Copyable {
        @usableFromInline
        internal var _next: () throws(Failure) -> Element?

        /// Construct an iterator from a `next()`-shaped closure.
        @inlinable
        public init(_ next: @escaping () throws(Failure) -> Element?) {
            self._next = next
        }
    }
}

extension Iterator.Witness {
    /// Advances and returns the next element, or `nil` at exhaustion.
    ///
    /// - Returns: the next element, or `nil` once the iterator is exhausted.
    /// - Throws: a `Failure` if the backing closure fails.
    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        try _next()
    }
}

extension Iterator.Witness {
    /// Construct an iterator by type-erasing any conforming iterator.
    ///
    /// The source iterator must itself admit closure capture (Copyable + Escapable).
    /// For `~Copyable` or `~Escapable` source iterators, conform to
    /// `Iterator.\`Protocol\`` directly rather than going through `Iterator.Witness`.
    @inlinable
    public init<Source: Iterator.`Protocol`>(_ source: Source)
    where Source.Element == Element, Source.Failure == Failure {
        var local = source
        self.init { () throws(Failure) -> Element? in
            try local.next()
        }
    }
}
