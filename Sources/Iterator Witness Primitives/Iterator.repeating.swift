//
//  Iterator.repeating.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// An iterator that yields `element` forever.
    ///
    /// Repetition requires `Copyable` `Element`: the element is re-yielded on every call to
    /// `next()`, which copies it. A move-only element cannot be repeated. Because there is no
    /// `~Copyable` / `~Escapable` capability to preserve, `repeating` is expressed directly as
    /// the closure-backed witness `Iterator.Witness` rather than a dedicated concrete type — the
    /// witness expresses repeating `Copyable` elements with no capability loss.
    ///
    /// For a single move-only or non-escaping element, use `Iterator.Once` directly.
    @inlinable
    public static func repeating<Element>(_ element: Element) -> Iterator.Witness<Element, Never> {
        Self.Witness<Element, Never> { element }
    }
}
