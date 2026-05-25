//
//  Iterate.swift
//  swift-iterator-primitives
//
//  The closure-backed iterator witness — top-level form of the codec-triple.
//

/// The type-erased iterator witness.
///
/// `Iterate<Element, Failure>` is a closure-backed implementation of
/// `Iterator.\`Protocol\``, suitable for wrapping any conforming iterator behind a single
/// nominal type or for constructing iterators directly from a `next()`-shaped closure.
///
/// ## Witness naming
///
/// The witness identifier is `Iterate` per the pattern doc §3 method-stem-divergence
/// rule: the agent's method is `next()`, but the witness echoes the verb form of the
/// *agent name* (`Iterator` → `Iterate`), not the method name (`Next` would be wrong).
///
/// ## Copyable-element limitation
///
/// Closure-backed storage limits `Element` to types that Swift's closure-capture
/// machinery accepts. Iterators yielding move-only or non-escaping elements should
/// conform to `Iterator.\`Protocol\`` directly rather than using `Iterate`.
public struct Iterate<Element, Failure: Swift.Error>: Iterator.`Protocol`, ~Copyable {
    @usableFromInline
    internal var _next: () throws(Failure) -> Element?

    /// Construct an iterator from a `next()`-shaped closure.
    @inlinable
    public init(_ next: @escaping () throws(Failure) -> Element?) {
        self._next = next
    }

    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        try _next()
    }
}

extension Iterate {
    /// Construct an iterator by type-erasing any conforming iterator.
    ///
    /// The source iterator must itself admit closure capture (Copyable + Escapable).
    /// For `~Copyable` or `~Escapable` source iterators, conform to
    /// `Iterator.\`Protocol\`` directly rather than going through `Iterate`.
    @inlinable
    public init<Source: Iterator.`Protocol`>(_ source: Source)
    where Source.Element == Element, Source.Failure == Failure
    {
        var local = source
        self.init { () throws(Failure) -> Element? in
            try local.next()
        }
    }
}
