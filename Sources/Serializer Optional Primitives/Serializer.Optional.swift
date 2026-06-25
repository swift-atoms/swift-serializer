//
//  Serializer.Optional.swift
//  swift-serializer-primitives
//
//  Compile-time optional serializer (for result builders).
//

extension Serializer {
    /// A serializer that optionally serializes if its wrapped serializer is present.
    ///
    /// Used by ``Serializer/Builder`` for `if` statements without `else`.
    public struct Optional<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        let wrapped: Wrapped?

        /// Creates a serializer from an optional wrapped serializer.
        ///
        /// - Parameter wrapped: The serializer to apply when present; `nil` is a no-op.
        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }
    }
}

extension Serializer.Optional: Serializer.`Protocol` {
    /// The wrapped serializer's output, made optional.
    public typealias Output = Wrapped.Output?

    /// The buffer type is inherited from the wrapped serializer.
    public typealias Buffer = Wrapped.Buffer

    /// The failure type is inherited from the wrapped serializer.
    public typealias Failure = Wrapped.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes the output via the wrapped serializer when both are present.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard let wrapped, let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
