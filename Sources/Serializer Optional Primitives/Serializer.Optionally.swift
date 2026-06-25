//
//  Serializer.Optionally.swift
//  swift-serializer-primitives
//
//  Runtime optional serializer (no-op on nil output).
//

extension Serializer {
    /// A serializer that serializes an optional output, no-op when nil.
    ///
    /// Unlike ``Serializer/Optional`` (compile-time optional, serializer
    /// instance may be nil), this is runtime optional — the output value may
    /// be nil.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let optionalSign = Serializer.Optionally(Sign())
    /// ```
    public struct Optionally<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        internal let wrapped: Wrapped

        /// Creates a serializer that no-ops when the output value is `nil`.
        ///
        /// - Parameter wrapped: The serializer to apply to a present value.
        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

extension Serializer.Optionally: Serializer.`Protocol` {
    /// The wrapped serializer's output, made optional.
    public typealias Output = Wrapped.Output?

    /// The buffer type is inherited from the wrapped serializer.
    public typealias Buffer = Wrapped.Buffer

    /// The failure type is inherited from the wrapped serializer.
    public typealias Failure = Wrapped.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes a present value via the wrapped serializer; no-op on `nil`.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
