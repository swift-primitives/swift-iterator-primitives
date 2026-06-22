//
//  Iterable+Reduce.swift
//  swift-iterator-primitives
//
//  Non-destructive fold terminal on the multipass attachable.
//
//  Span-primitive (SE-0516): drives the bulk `next(maximumCount:) -> Swift.Span<Element>` loop, offering
//  each element to `accumulate` via the borrowing addressor `span[i]` — so move-only and
//  non-escaping element types fold without a Copyable gate.
//

public import Cardinal_Primitives
public import Either_Primitives
public import Iterator_Chunk_Primitives

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {
    /// Folds the elements into `initial`, mutating the accumulator with each element.
    ///
    /// Non-destructive (borrowing, multipass). The accumulator `Result` may be move-only:
    /// consumed in, mutated in place per element, moved out. Each element is offered to
    /// `accumulate` by borrow over the iterator's span; the closure's typed error `E` is
    /// propagated unerased.
    ///
    /// - Parameters:
    ///   - initial: the starting accumulator, consumed into the fold.
    ///   - accumulate: folds each element into the accumulator in place; may throw `E`.
    /// - Returns: the final accumulator.
    /// - Throws: any error of type `E` thrown by `accumulate`.
    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Iterator.Element) throws(E) -> Void
    ) throws(E) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                try accumulate(&result, span[i])
            }
        }
        return result
    }
}

// MARK: - Fallible iterators

extension Iterable where Self: ~Copyable & ~Escapable {
    /// Folds the elements into `initial`, for a fallible iterator.
    ///
    /// The iterator's `Failure` and the closure's `E` are fused into
    /// `Either<E, Iterator.Failure>`. The `throws(E)` overload is more specific and wins for
    /// infallible iterators.
    ///
    /// - Parameters:
    ///   - initial: the starting accumulator, consumed into the fold.
    ///   - accumulate: folds each element into the accumulator in place; may throw `E`.
    /// - Returns: the final accumulator.
    /// - Throws: `Either<E, Iterator.Failure>`.
    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Iterator.Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do { span = try iterator.next(maximumCount: Cardinal(UInt.max)) } catch { throw Either.right(error) }
            if span.isEmpty { return result }
            for i in span.indices {
                do {
                    try accumulate(&result, span[i])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
