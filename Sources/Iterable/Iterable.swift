//
//  Iterable.swift
//  swift-iterator-primitives
//
//  The Iterable attachable — capability attachment for the iterator codec-triple.
//

/// A type that has a canonical iterator.
///
/// `Iterable` is the codec-triple's attachable for iteration: conformers declare a
/// canonical way to iterate themselves via `makeIterator()`. Types opt in to expose
/// iteration without themselves being iterators.
///
/// ## Foundation layer
///
/// `Iterable` is the *foundation* attachable. `Sequenceable` (in
/// `swift-sequencer-primitives`, when it lands) refines it with the algorithm suite
/// (map/filter/reduce/…). A type that is `Sequenceable` is automatically `Iterable`.
public protocol Iterable: ~Copyable, ~Escapable {
    /// The iterator type this instance produces.
    ///
    /// (Module-qualified to avoid shadowing the outer `Iterator` namespace; the
    /// associated type's own name `Iterator` would otherwise collide with the
    /// namespace identifier inside the constraint expression.)
    associatedtype Iterator: Iterator_Primitive.Iterator.`Protocol`

    /// Construct a fresh iterator over this value.
    borrowing func makeIterator() -> Iterator
}
