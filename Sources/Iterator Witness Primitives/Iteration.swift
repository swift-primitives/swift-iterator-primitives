//
//  Iteration.swift
//  swift-iterator-primitives
//
//  The result-noun alias for the iterator witness.
//

/// The result-noun alias for the iterator witness `Iterator.Witness`.
///
/// `Iteration` is the deverbal result-noun of *iterate* and names the type-erased,
/// closure-backed value you *hold* — the witness-side twin of the gerund protocol alias
/// `Iterating` (which names the capability you *conform to*). Per `[PKG-NAME-015]` all four
/// gates clear (deverbal result-noun ✓, first-class English noun ✓, free in the ecosystem ✓,
/// sole alias ✓), so this alias is the sanctioned, `[API-NAME-004a]`-exempt witness-alias.
///
/// Consumers may hold an iterator witness as either `Iteration<Element, Failure>` or
/// `Iterator.Witness<Element, Failure>`; the two are the same type.
public typealias Iteration = Iterator.Witness
