//
//  Iterating.swift
//  swift-iterator-primitives
//
//  The active gerund alias for the iterator capability protocol.
//

/// The active-capability gerund alias for `Iterator.\`Protocol\``.
///
/// Per `[PKG-NAME-002]` / `operation-domain-naming-and-organization.md` §4.1, the active
/// capability protocol is declared as the nested `Iterator.\`Protocol\`` and exported at module
/// scope under its gerund reading so conformance and constraint sites read as English:
///
/// ```swift
/// struct JSONTokens: Iterating { … }                       // "is iterating" — natural
/// func drive<I: Iterating>(_ i: inout I) where I.Element == Int { … }
/// ```
///
/// `Iterator.\`Protocol\`` remains the canonical declaration the alias targets, and is used where
/// `Iterating` would be ambiguous. `Iterating` names the active capability you *conform to*; the
/// result-noun `Iteration` (`[PKG-NAME-015]`) names the witness value you *hold*.
public typealias Iterating = Iterator.`Protocol`
