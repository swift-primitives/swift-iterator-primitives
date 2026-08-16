import Iterator_Chunk_Primitives
import Iterator_Primitives_Test_Support

/// A minimal span-primitive `Iterable` fixture: vends a fresh `Iterator.Chunk` over its stored
/// values' span each call, so iteration is non-destructive (multipass).
private struct IntSource: Iterable {
    let values: [Int]
}

extension IntSource {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator_Chunk_Primitives.Iterator.Chunk<Int> {
        Iterator_Chunk_Primitives.Iterator.Chunk(values.span)
    }
}

/// A `~Escapable` `Iterable` fixture — a cursor over a borrowed span. This shape is the one the
/// Property fluent-accessor surface cannot express, because `Property` requires an Escapable base.
private struct IntCursor: Iterable, ~Escapable {
    let values: Swift.Span<Int>

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>) {
        self.values = values
    }
}

extension IntCursor {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator_Chunk_Primitives.Iterator.Chunk<Int> {
        Iterator_Chunk_Primitives.Iterator.Chunk(values)
    }
}

@Suite struct `Iterable ForEach Tests` {
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Unit {}
    @Suite struct `Escapability` {}
}

extension `Iterable ForEach Tests`.Unit {
    @Test
    func `forEach visits every element in order`() {
        let source = IntSource(values: [1, 2, 3])
        var collected: [Int] = []
        source.forEach { collected.append($0) }
        #expect(collected == [1, 2, 3])
    }

    @Test
    func `forEach is non-destructive — the container iterates again`() {
        let source = IntSource(values: [10, 20])
        var first: [Int] = []
        source.forEach { first.append($0) }
        var second: [Int] = []
        source.forEach { second.append($0) }
        #expect(first == [10, 20])
        #expect(second == [10, 20])
    }

    @Test
    func `forEach propagates the body's typed error, stopping iteration`() {
        enum Stop: Swift.Error { case now }
        let source = IntSource(values: [1, 2, 3, 4])
        var seen: [Int] = []
        var threw = false
        do throws(Stop) {
            try source.forEach { element throws(Stop) in
                seen.append(element)
                if element == 2 { throw Stop.now }
            }
        } catch {
            threw = true
        }
        #expect(threw)
        #expect(seen == [1, 2])
    }
}

extension `Iterable ForEach Tests`.`Escapability` {
    /// The iteration-terminal **surface** guarantee.
    ///
    /// The SE-0507 canary that previously lived here has been retired: it asserted that
    /// `borrow` accessors (`BorrowAndMutateAccessors`) were unavailable, and that gate is gone —
    /// the feature is enabled by default from Swift 6.4, this package's CI release floor.
    ///
    /// Its retirement does not move the surface to the Property fluent-accessor pattern, because
    /// the binding constraint was never the accessor kind: `Property<Tag, Base>` requires an
    /// **Escapable** `Base`, while these terminals are declared on `Self: ~Copyable & ~Escapable`
    /// and must reach `~Escapable` iterables (cursors). This test guards exactly that capability —
    /// the one a Property surface would take away.
    @Test
    func `forEach reaches a ~Escapable iterable`() {
        let values = [1, 2, 3, 4]
        var collected: [Int] = []
        let cursor = IntCursor(values.span)
        cursor.forEach { collected.append($0) }
        #expect(collected == [1, 2, 3, 4])
    }
}
