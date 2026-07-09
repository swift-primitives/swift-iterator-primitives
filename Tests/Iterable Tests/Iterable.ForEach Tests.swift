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

@Suite struct `Iterable ForEach Tests` {
    @Suite struct Unit {}
    @Suite struct Canary {}
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

extension `Iterable ForEach Tests`.Canary {
    /// CI tripwire for the iteration-terminal **surface** decision
    /// (`Research/iterable-iteration-terminal-surface.md`).
    ///
    /// While SE-0507 `borrow` accessors (`BorrowAndMutateAccessors`) are unavailable in the
    /// production compiler, `Iterable`'s iteration terminals are plain `borrowing func`s — the
    /// Property fluent-accessor surface cannot host iteration, because its base access is a
    /// `_read` coroutine (statement-scoped) and an iterator can't be held across the loop.
    ///
    /// When the feature becomes **enabled** in the build, this test fails — prompting a revisit
    /// of the Property-tag surface (and retirement of this canary).
    @Test
    func `SE-0507 borrow accessors remain unavailable (revisit the Property surface when this fails)`() {
        #if hasFeature(BorrowAndMutateAccessors)
            Issue.record(
                """
                SE-0507 borrow accessors (BorrowAndMutateAccessors) are now enabled. The Iterable \
                iteration-terminal surface can likely move from plain `borrowing func` to the \
                Property fluent-accessor pattern (Property.Borrow via a `borrow` accessor). \
                Revisit Research/iterable-iteration-terminal-surface.md and retire this canary.
                """
            )
        #endif
    }
}
