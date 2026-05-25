import Iterator_Primitives_Test_Support

@Suite("Iterator.Empty Tests")
struct IteratorEmptyTests {
    @Suite struct Unit {}
}

extension IteratorEmptyTests.Unit {
    @Test
    func `empty iterator yields nothing`() {
        var iter = Iterator.Empty<Int>()
        #expect(iter.next() == nil)
    }

    @Test
    func `empty iterator stays exhausted across repeated calls`() {
        var iter = Iterator.Empty<String>()
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}
