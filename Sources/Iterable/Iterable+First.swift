//
//  Iterable+First.swift
//  swift-iterator-primitives
//
//  Non-destructive lookup terminal on the multipass attachable.
//
//  Span-primitive (SE-0516): drives the bulk `next(maximumCount:) -> Swift.Span<Element>` loop. The
//  matched element is copied out of the borrowed span and returned by value, so this terminal
//  keeps its `Element: Copyable & Escapable` gate — that gate is intrinsic to *extracting* an
//  element past the borrow, NOT to iteration.
//

public import Cardinal_Primitives
public import Either_Primitives
public import Iterator_Chunk_Primitives

extension Iterable
where
    Self: ~Copyable & ~Escapable,
    Iterator.Failure == Never,
    Iterator.Element: Copyable & Escapable
{
    /// Returns the first element satisfying `predicate`, or `nil` if none does.
    ///
    /// Non-destructive (borrowing, multipass) — stops at the first match.
    /// `Element: Copyable & Escapable` because the matched element is copied out of the
    /// borrowed span and returned by value (a non-escaping element cannot be returned).
    /// The predicate's typed error `E` is propagated unerased.
    ///
    /// - Parameter predicate: a closure called with a borrow of each element; may throw `E`.
    /// - Returns: the first matching element, or `nil`.
    /// - Throws: any error of type `E` thrown by `predicate`.
    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Iterator.Element? {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                let element = span[i]
                if try predicate(element) { return element }
            }
        }
        return nil
    }
}

// MARK: - Fallible iterators

extension Iterable
where Self: ~Copyable & ~Escapable, Iterator.Element: Copyable & Escapable {
    /// Returns the first element satisfying `predicate`, or `nil`, for a fallible iterator.
    ///
    /// The iterator's `Failure` and the predicate's `E` are fused into
    /// `Either<E, Iterator.Failure>`. The `throws(E)` overload is more specific and wins for
    /// infallible iterators.
    ///
    /// - Parameter predicate: a closure called with a borrow of each element; may throw `E`.
    /// - Returns: the first matching element, or `nil`.
    /// - Throws: `Either<E, Iterator.Failure>`.
    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Iterator.Element? {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do { span = try iterator.next(maximumCount: Cardinal(UInt.max)) } catch { throw Either.right(error) }
            if span.isEmpty { return nil }
            for i in span.indices {
                let element = span[i]
                do {
                    if try predicate(element) { return element }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
