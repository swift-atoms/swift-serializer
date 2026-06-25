//
//  Serializer.Filter.swift
//  swift-serializer-primitives
//
//  Output validation combinator.
//

extension Serializer {
    /// A serializer that filters its input using a predicate.
    ///
    /// If the predicate returns false, serialization fails before delegating to
    /// the upstream serializer.
    ///
    /// Created via `serializer.filter(_:)`.
    public struct Filter<Upstream: Serializer.`Protocol`> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let predicate: (Upstream.Output) -> Bool

        /// Creates a filtering serializer.
        ///
        /// - Parameters:
        ///   - upstream: The serializer to delegate to when the predicate passes.
        ///   - predicate: A validation predicate run against the input value.
        @inlinable
        public init(
            upstream: Upstream,
            predicate: @escaping (Upstream.Output) -> Bool
        ) {
            self.upstream = upstream
            self.predicate = predicate
        }
    }
}

extension Serializer.Filter {
    /// Errors thrown by a ``Serializer/Filter`` when its predicate rejects an input.
    public enum Error: Swift.Error {
        /// The input value did not satisfy the filter predicate.
        case validationFailed(value: String, reason: String)
    }
}

extension Serializer.Filter: Serializer.`Protocol` {
    /// The output type is inherited from the upstream serializer.
    public typealias Output = Upstream.Output

    /// The buffer type is inherited from the upstream serializer.
    public typealias Buffer = Upstream.Buffer

    /// An upstream failure or a predicate-rejection error.
    public typealias Failure = Either<Upstream.Failure, Serializer.Filter<Upstream>.Error>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes via the upstream serializer when the predicate accepts the input.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard predicate(output) else {
            throw .right(.validationFailed(value: "\(output)", reason: "filter predicate"))
        }
        do {
            try upstream.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
