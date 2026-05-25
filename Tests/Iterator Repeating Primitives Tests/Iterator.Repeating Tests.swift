import Iterator_Primitives_Test_Support

@Suite("Iterator.Repeating Tests")
struct IteratorRepeatingTests {
    @Suite struct Unit {}
}

extension IteratorRepeatingTests.Unit {
    @Test
    func `repeating iterator yields same element repeatedly`() {
        var iter = Iterator.Repeating(7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
    }

    @Test
    func `repeating iterator works with string element`() {
        var iter = Iterator.Repeating("ping")
        #expect(iter.next() == "ping")
        #expect(iter.next() == "ping")
    }
}
