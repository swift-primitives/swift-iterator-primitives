//
//  Iterable+Contains.swift
//  swift-iterator-primitives
//
//  Non-destructive existence terminal on the multipass attachable.
//
//  Span-primitive (SE-0516): drives the bulk `next(maximumCount:) -> Span<Element>` loop, offering
//  each element to `predicate` via the borrowing addressor `span[i]` — so move-only and
//  non-escaping element types work (no Copyable gate).
//

public import Cardinal_Primitives
public import Either_Primitives
public import Iterator_Chunk_Primitives

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {
    /// Returns whether any element satisfies `predicate`.
    ///
    /// Non-destructive (borrowing, multipass) — stops at the first match. Each element is
    /// offered to `predicate` by borrow over the iterator's span, so move-only and non-escaping
    /// element types work. The closure's typed error `E` is propagated unerased (`E == Never` for
    /// a non-throwing predicate, making the call non-throwing).
    ///
    /// - Parameter predicate: a closure called with a borrow of each element; may throw `E`.
    /// - Returns: `true` at the first match; `false` if none matches.
    /// - Throws: any error of type `E` thrown by `predicate`.
    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                if try predicate(span[i]) { return true }
            }
        }
        return false
    }
}

// MARK: - Fallible iterators

extension Iterable where Self: ~Copyable & ~Escapable {
    /// Returns whether any element satisfies `predicate`, for a fallible iterator.
    ///
    /// The iterator's `Failure` and the predicate's `E` are fused into
    /// `Either<E, Iterator.Failure>` (`.left` = predicate error, `.right` = iterator failure).
    /// The `throws(E)` overload is more specific and wins for infallible iterators.
    ///
    /// - Parameter predicate: a closure called with a borrow of each element; may throw `E`.
    /// - Returns: `true` at the first match; `false` if none matches.
    /// - Throws: `Either<E, Iterator.Failure>`.
    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Bool {
        var iterator = makeIterator()
        while true {
            let span: Span<Iterator.Element>
            do { span = try iterator.next(maximumCount: Cardinal(UInt.max)) } catch { throw Either.right(error) }
            if span.isEmpty { return false }
            for i in span.indices {
                do {
                    if try predicate(span[i]) { return true }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
