import Iterator_Primitives_Test_Support

@Suite("Iterate Tests")
struct IterateTests {
    @Suite struct Unit {}
    @Suite struct TypeErasure {}
}

extension IterateTests.Unit {
    @Test
    func `closure-backed iterator yields then exhausts`() {
        var values = [1, 2, 3]
        var iter = Iterate<Int, Never> {
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
        var iter = Iterate<Int, Never> { nil }
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}

extension IterateTests.TypeErasure {
    @Test
    func `wraps Iterator dot Once`() {
        // Once<Int> is Copyable & Escapable — admissible source for the
        // closure-backed witness.
        let source = Iterator.Once(42)
        var iter = Iterate(source)

        #expect(iter.next() == 42)
        #expect(iter.next() == nil)
    }

    @Test
    func `wraps Iterator dot Repeating`() {
        // Repeating<Int> is Copyable & Escapable — admissible source for the
        // closure-backed witness.
        let source = Iterator.Repeating(7)
        var iter = Iterate(source)

        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
    }

    // Iterator.Empty<Element> is `~Copyable, ~Escapable` and intentionally
    // CANNOT be wrapped by `Iterate` — the closure-backed witness's source
    // parameter implicitly requires Copyable + Escapable. Empty must be used
    // directly. This is the documented v0 limitation of closure-backed type
    // erasure on noncopyable iterators.
}
