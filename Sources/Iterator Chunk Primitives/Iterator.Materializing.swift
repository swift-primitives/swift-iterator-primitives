//
//  Iterator.Materializing.swift
//  swift-iterator-primitives
//

public import Cardinal_Primitives
public import Iterator_Primitive
public import Iterator_Protocol

extension Iterator {
    /// Presents a scalar generator as a bulk iterator, lending one materialised element per step.
    ///
    /// The span-primitive adapter for **generators** — scalar iterators that compute or sparse-yield
    /// their elements and therefore have no contiguously-stored `Span<Element>` to project (bit
    /// vectors, `Single`, cyclic groups, hash occupancy, …). The institute analog of SE-0516's
    /// `BorrowingIteratorAdapter`: it wraps a scalar `Iterator.`Protocol`` and presents it as a bulk
    /// `__IteratorChunkProtocol` by materialising **one** element per step into an owned reused slot
    /// and lending a borrowed 1-element `Span` over it (an empty span signals exhaustion). The slot is
    /// overwritten in place, so steady-state iteration allocates nothing; the lent span is valid only
    /// until the next `next(maximumCount:)` (the SE-0516 contract — materialising iterators reuse one
    /// buffer). `maximumCount` is an upper bound the one-element adapter honours trivially.
    ///
    /// Copyable-only on the element (`Source.Element: Copyable & Escapable`): a materialised element is
    /// copied out of the scalar `next()` into the owned slot, which excludes ~Copyable / ~Escapable
    /// element kinds — exactly the constraint every generator conformer already carries. (Dense,
    /// contiguously-stored containers do NOT use this adapter: they vend `Iterator.Chunk` directly over
    /// their `span`, which carries both element kinds.)
    public struct Materializing<Source: Iterator.`Protocol` & ~Copyable & ~Escapable>:
        __IteratorChunkProtocol, ~Copyable, ~Escapable
    where Source.Element: Copyable & Escapable {
        @usableFromInline var source: Source
        @usableFromInline var slot: [Source.Element]

        /// The element kind this iterator lends — the wrapped source's element.
        public typealias Element = Source.Element

        /// The error type — the wrapped source's failure.
        public typealias Failure = Source.Failure

        /// Wrap a scalar generator.
        ///
        /// The adapter consumes and owns the source iterator.
        @inlinable
        @_lifetime(copy source)
        public init(_ source: consuming Source) {
            self.source = source
            self.slot = []
        }

        /// Materialise the next scalar element into the owned slot and lend a 1-element span over it;
        /// an empty span signals exhaustion.
        @inlinable
        @_lifetime(&self)
        public mutating func next(
            maximumCount: some Carrier.`Protocol`<Cardinal>
        ) throws(Source.Failure) -> Span<Source.Element> {
            if let value = try source.next() {
                if slot.isEmpty { slot.append(value) } else { slot[0] = value }
                return slot.span.extracting(first: 1)
            }
            return slot.span.extracting(first: 0)
        }
    }
}
