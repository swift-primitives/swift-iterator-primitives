//
//  Iterable+AllSatisfy.swift
//  swift-iterator-primitives
//
//  Universal-quantifier terminal on the multipass attachable.
//
//  Dual of `contains(where:)`: `allSatisfy(p) == !contains { !p }`. Inherits the
//  span-primitive (SE-0516) borrowing iteration from `contains`, so move-only and
//  non-escaping element types work (no Copyable gate).
//

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {
    /// Returns whether every element satisfies `predicate`.
    ///
    /// Non-destructive (borrowing, multipass) — stops at the first element that fails
    /// `predicate`. Vacuously `true` for an empty collection. Each element is offered to
    /// `predicate` by borrow, so move-only and non-escaping element types work. The
    /// closure's typed error `E` is propagated unerased (`E == Never` for a non-throwing
    /// predicate, making the call non-throwing).
    ///
    /// - Parameter predicate: a closure called with a borrow of each element; may throw `E`.
    /// - Returns: `true` if every element matches; `false` at the first failure.
    /// - Throws: any error of type `E` thrown by `predicate`.
    @inlinable
    public borrowing func allSatisfy<E: Swift.Error>(
        _ predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        try !contains(where: { (element: borrowing Iterator.Element) throws(E) -> Bool in
            try !predicate(element)
        })
    }
}
