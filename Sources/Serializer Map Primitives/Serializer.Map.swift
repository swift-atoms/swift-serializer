//
//  Serializer.Map.swift
//  swift-serializer-primitives
//
//  Pure contravariant output transformation.
//

extension Serializer {
    /// A serializer that transforms its input value before delegating to another serializer.
    ///
    /// This is the contravariant `map` operation for serializers. It applies a pure
    /// transformation to the input value, producing the upstream serializer's expected
    /// output, then delegates to the upstream serializer.
    ///
    /// Created via `serializer.map(_:)`.
    ///
    /// ## Throwing variant
    ///
    /// For transforms that may fail, see ``Serializer/Map/Throwing``, created
    /// via `serializer.tryMap(_:)`. The throwing variant inherits `Upstream`
    /// and `NewOutput` from this type and adds a new error parameter `E`.
    public struct Map<Upstream: Serializer.`Protocol`, NewOutput> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform: (NewOutput) -> Upstream.Output

        /// Creates a mapping serializer.
        ///
        /// - Parameters:
        ///   - upstream: The serializer to delegate to after transforming the input.
        ///   - transform: A pure function from the new input to the upstream output.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (NewOutput) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Serializer.Map: Serializer.`Protocol` {
    /// The buffer type is inherited from the upstream serializer.
    public typealias Buffer = Upstream.Buffer

    /// The failure type is inherited from the upstream serializer.
    public typealias Failure = Upstream.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Transforms the input, then serializes it via the upstream serializer.
    @inlinable
    public func serialize(_ output: NewOutput, into buffer: inout Buffer) throws(Failure) {
        try upstream.serialize(transform(output), into: &buffer)
    }
}
