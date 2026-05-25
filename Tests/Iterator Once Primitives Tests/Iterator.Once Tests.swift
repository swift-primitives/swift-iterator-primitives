import Iterator_Primitives_Test_Support

@Suite("Iterator.Once Tests")
struct IteratorOnceTests {
    @Suite struct Unit {}
}

extension IteratorOnceTests.Unit {
    @Test
    func `once iterator yields one element then nil`() {
        var iter = Iterator.Once(42)
        #expect(iter.next() == 42)
        #expect(iter.next() == nil)
    }

    @Test
    func `once iterator stays exhausted across repeated calls`() {
        var iter = Iterator.Once("hello")
        #expect(iter.next() == "hello")
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}
