import Iterator_Primitives_Test_Support

/// A minimal bulk iterator draining its buffer one element per `next`.
///
/// Lends a span that borrows its own storage. Returning at most `maximumCount` (here, at most
/// one) trivially honors the bound, so it needs no count arithmetic — enough to exercise the
/// protocol and the derived `next()`.
private struct DripBulk: Iterator.Chunk.`Protocol` {
    typealias Element = Int
    typealias Failure = Never
    var storage: [Int]
    var pos: Int = 0
    init(_ storage: [Int]) { self.storage = storage }

    @_lifetime(&self)
    mutating func next(maximumCount: some Carrier.`Protocol`<Cardinal>) -> Span<Int> {
        guard pos < storage.count else { return storage.span.extracting(pos..<pos) }
        let start = pos
        pos += 1
        return storage.span.extracting(start..<(start + 1))
    }
}

@Suite("Iterator.Chunk Tests")
struct IteratorContiguousTests {
    @Suite struct Unit {}
}

extension IteratorContiguousTests.Unit {
    @Test
    func `next yields a borrowed span of the next element`() {
        var iter = DripBulk([10, 20, 30])
        let span = iter.next(maximumCount: Cardinal(4))
        // Span is ~Escapable; extract Escapable values before #expect (the macro captures its
        // argument in a closure, which would require Escapable).
        let count = span.count
        let first = span[0]
        #expect(count == 1)
        #expect(first == 10)
    }

    @Test
    func `next returns an empty span at exhaustion`() {
        var iter = DripBulk([Int]())
        let span = iter.next(maximumCount: Cardinal.one)
        let isEmpty = span.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `derived next drains the bulk iterator one element at a time`() {
        var iter = DripBulk([1, 2, 3])
        #expect(iter.next() == 1)
        #expect(iter.next() == 2)
        #expect(iter.next() == 3)
        #expect(iter.next() == nil)
    }

    @Test
    func `Iterator.Chunk lends chunked sub-spans up to maximumCount, then exhausts`() {
        let array = [10, 20, 30, 40, 50]
        var iter = Iterator.Chunk(array.span)

        // Each span borrows `iter` (@_lifetime(&self)), so it must die before the next call —
        // hence the `do` scopes. Extract Escapable values (span is ~Escapable) before asserting.
        do {
            let chunk = iter.next(maximumCount: Cardinal(2))
            let count = chunk.count
            let a = chunk[0]
            let b = chunk[1]
            #expect(count == 2)
            #expect(a == 10)
            #expect(b == 20)
        }
        do {
            let chunk = iter.next(maximumCount: Cardinal(2))
            let count = chunk.count
            let a = chunk[0]
            let b = chunk[1]
            #expect(count == 2)
            #expect(a == 30)
            #expect(b == 40)
        }
        // The derived scalar next() drains the remainder one element at a time.
        #expect(iter.next() == 50)
        #expect(iter.next() == nil)
    }
}
