//
//  Serializer.swift
//  swift-serializer-primitives
//
//  Namespace for serialization primitives and combinators.
//
//  The family-as-enum-namespace + nested-Witness shape (validated in
//  `family-as-enum-namespace-witness-nested`, CONFIRMED 6/6) restores the
//  enum-namespace at the root. The closure-backed witness lives as one
//  combinator type among many, nested under the namespace as
//  ``Serializer/Witness``.
//

/// Namespace for serialization primitives and combinators.
///
/// `Serializer.Protocol` (the nested protocol) is the canonical surface for
/// one-way, machine-readable serialization with O(1) amortized append
/// performance.
///
/// ``Serializer/Witness`` is the closure-backed conformer used for ad-hoc
/// witnesses; additional combinator types (``Serializer/Map``,
/// ``Serializer/Filter``, ``Serializer/Sequence``, ``Serializer/Many``,
/// ``Serializer/Literal``, …) nest under this namespace.
public enum Serializer {}
