//
//  Iterator.swift
//  swift-iterator-primitives
//
//  The Iterator namespace — agent of the codec-triple applied to iteration.
//

/// Namespace for iterator-domain types.
///
/// `Iterator` is the agent namespace of the codec-triple applied to iteration. It hosts
/// `Iterator.\`Protocol\`` (the agent protocol) and concrete iterator types
/// (`Iterator.Empty`, `Iterator.Once`, `Iterator.Repeating`).
///
/// The witness `Iterate<Element, Failure>` lives at top level (not nested here), per the
/// agent-witness-attachable pattern's witness-identifier method-stem-divergence rule:
/// the agent's method is `next()`, but the witness echoes the verb form of the *agent
/// name* (`Iterator` → `Iterate`), not the method name.
///
/// The attachable `Iterable` also lives at top level.
public enum Iterator {}
