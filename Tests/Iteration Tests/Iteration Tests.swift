import Iterator_Primitives_Test_Support

/// A minimal Copyable & Escapable iterator used to exercise type erasure.
///
/// Every concrete iterator in the family (`Empty`, `Iterator.Once`) is `~Copyable, ~Escapable`
/// and so cannot be type-erased through the closure-backed witness (whose source parameter
/// implicitly requires Copyable + Escapable for closure capture). This stands in for a
/// consumer-provided Copyable iterator.
private struct CountingIterator: Iterator.`Protocol` {
    var n: Int
    init(upTo n: Int) { self.n = n }
    mutating func next() -> Int? {
        guard n > 0 else { return nil }
        defer { n -= 1 }
        return n
    }
}

@Suite("Iteration Tests")
struct IterationTests {
    @Suite struct Unit {}
    @Suite struct TypeErasure {}
    @Suite struct Repeating {}
}

extension IterationTests.Unit {
    @Test
    func `closure-backed iterator yields then exhausts`() {
        var values = [1, 2, 3]
        var iter = Iteration<Int, Never> {
            guard !values.isEmpty else { return nil }
            return values.removeFirst()
        }

        #expect(iter.next() == 1)
        #expect(iter.next() == 2)
        #expect(iter.next() == 3)
        #expect(iter.next() == nil)
    }

    @Test
    func `empty closure-backed iterator yields nothing`() {
        var iter = Iteration<Int, Never> { nil }
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}

extension IterationTests.TypeErasure {
    @Test
    func `wraps a Copyable source iterator`() {
        let source = CountingIterator(upTo: 2)
        var iter = Iteration(source)

        #expect(iter.next() == 2)
        #expect(iter.next() == 1)
        #expect(iter.next() == nil)
    }
}

extension IterationTests.Repeating {
    @Test
    func `repeating factory yields the element forever`() {
        // Iterator.repeating(_:) collapses to the witness — repetition requires Copyable.
        var iter = Iterator.repeating(7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
    }
}
