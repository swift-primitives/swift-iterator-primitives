//
//  Iterator.Once.swift
//  swift-iterator-primitives
//

extension Iterator {
    /// An iterator that yields exactly one *owned* element, then is exhausted.
    ///
    /// `Iterator.Once<Element>` owns its element and *gives it away* on the first call to `next()`,
    /// returning `nil` thereafter. It permits `~Copyable & ~Escapable` `Element`: the element
    /// lives in an enum payload and is *moved* out on the first `next()` as the iterator
    /// transitions `.pending` → `.done`, so move-only (unique handles) and non-escaping (views
    /// into borrowed storage) elements are supported.
    ///
    /// `Iterator.Once` is the *source* form of a single element — it owns the element and yields it. This
    /// is distinct from a single-element *container* (which keeps its element for repeated,
    /// multipass access); such a container is a separate type. `Iterator.Once` is what a `Copyable`
    /// single-element container vends as its iterator (from a copy of its element); for an element
    /// to be re-yielded forever, use `Iterator.repeating(_:)` (which also requires `Copyable`).
    ///
    /// The enum shape is load-bearing: yielding a move-only element requires moving it out of
    /// storage and leaving the iterator valid, which `consume self` + full reinitialization
    /// expresses but a stored `Element?` field cannot (partial reinitialization after consume is
    /// rejected, and `swap` requires `Escapable`).
    public enum Once<Element: ~Copyable & ~Escapable>: Iterator.`Protocol`, ~Copyable, ~Escapable {
        /// The element has not yet been yielded.
        case pending(Element)
        /// The element has been yielded; iteration is exhausted.
        case done

        /// The error type, `Never` — yielding a stored element cannot fail.
        public typealias Failure = Never

        /// Construct an iterator yielding `element` exactly once.
        @inlinable
        @_lifetime(copy element)
        public init(_ element: consuming Element) {
            self = .pending(element)
        }

        /// Yield the element on the first call, `nil` on every subsequent call.
        @inlinable
        @_lifetime(&self)
        public mutating func next() -> Element? {
            switch consume self {
            case .pending(let element):
                self = .done
                return element

            case .done:
                self = .done
                return nil
            }
        }
    }
}
