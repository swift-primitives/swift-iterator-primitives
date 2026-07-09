import Cardinal_Primitives
import Carrier_Primitives
import Either_Primitives
import Iterator_Chunk_Primitives
import Iterator_Primitives_Test_Support

private enum SourceError: Swift.Error { case boom }

/// A fallible **span-primitive** iterator that throws once its cursor reaches `failAt`.
///
/// `next(maximumCount:)` yields one element per step over a borrowed span, and throws
/// `SourceError` once the cursor reaches `failAt`. Yielding one element at a time preserves the
/// original scalar fixture's `failAt` semantics under the span loop.
private struct FailingChunk: ~Copyable, ~Escapable {
    @usableFromInline let span: Swift.Span<Int>
    @usableFromInline let failAt: Int
    @usableFromInline var position: Int

    @_lifetime(copy span)
    init(_ span: Swift.Span<Int>, failAt: Int) {
        self.span = span
        self.failAt = failAt
        self.position = 0
    }
}

extension FailingChunk: __IteratorChunkProtocol {
    typealias Element = Int
    typealias Failure = SourceError

    @_lifetime(&self)
    mutating func next(maximumCount: some Carrier.`Protocol`<Cardinal>) throws(SourceError) -> Swift.Span<Int> {
        if position == failAt { throw .boom }
        guard position < span.count else { return span.extracting(first: 0) }
        let result = span.extracting(droppingFirst: position).extracting(first: 1)
        position += 1
        return result
    }
}

private struct FailingSource: Iterable {
    let values: [Int]
    let failAt: Int
}

extension FailingSource {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> FailingChunk {
        FailingChunk(values.span, failAt: failAt)
    }
}

@Suite struct `Iterable ForEach Fallible Tests` {
    @Suite struct Unit {}
}

extension `Iterable ForEach Fallible Tests`.Unit {
    @Test
    func `an iterator failure surfaces as Either.right`() {
        let source = FailingSource(values: [10, 20, 30], failAt: 2)
        var seen: [Int] = []
        var isRight = false
        do throws(Either<Never, SourceError>) {
            try source.forEach { seen.append($0) }
        } catch {
            // error: Either<Never, SourceError> — the fallible overload was selected.
            if case .right = error { isRight = true }
        }
        #expect(isRight)
        #expect(seen == [10, 20])
    }

    @Test
    func `a body error surfaces as Either.left`() {
        enum Stop: Swift.Error { case now }
        let source = FailingSource(values: [10, 20, 30], failAt: 99)  // iterator never fails
        var seen: [Int] = []
        var isLeft = false
        do throws(Either<Stop, SourceError>) {
            try source.forEach { element throws(Stop) in
                seen.append(element)
                if element == 20 { throw Stop.now }
            }
        } catch {
            // error: Either<Stop, SourceError>
            if case .left = error { isLeft = true }
        }
        #expect(isLeft)
        #expect(seen == [10, 20])
    }

    @Test
    func `fallible contains surfaces an iterator failure as Either.right`() {
        let source = FailingSource(values: [10, 20, 30], failAt: 1)
        var isRight = false
        do throws(Either<Never, SourceError>) {
            _ = try source.contains { $0 == 99 }
        } catch {
            if case .right = error { isRight = true }
        }
        #expect(isRight)
    }

    @Test
    func `fallible reduce surfaces a closure error as Either.left`() {
        enum Stop: Swift.Error { case now }
        let source = FailingSource(values: [10, 20, 30], failAt: 99)
        var isLeft = false
        do {
            _ = try source.reduce(into: 0) { accumulator, element in
                if element == 20 { throw Stop.now }
                accumulator += element
            }
        } catch {
            if case .left = error { isLeft = true }
        }
        #expect(isLeft)
    }
}
