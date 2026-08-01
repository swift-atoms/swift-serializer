//
//  Serializer.Filter.Error.swift
//  swift-serializer-primitives
//
//  Error type for the filter combinator, hoisted to module scope so it is
//  never accidentally generic over `Serializer.Filter`'s `Upstream` parameter.
//

/// Errors thrown by a ``Serializer/Filter`` when its predicate rejects an input.
///
/// Hoisted to non-generic module scope per API-ERR-009: nesting this inside the
/// generic `Serializer.Filter<Upstream>` would make it an accidentally-generic
/// `@error` SIL result that never uses `Upstream`, which can trip
/// `FunctionSignatureOpts` under `-O -enable-default-cmo` (swiftlang/swift#89617).
public enum __SerializerFilterError: Swift.Error {
    /// The input value did not satisfy the filter predicate.
    case validationFailed(value: String, reason: String)
}

extension Serializer.Filter {
    /// Errors thrown by a ``Serializer/Filter`` when its predicate rejects an input.
    public typealias Error = __SerializerFilterError
}
