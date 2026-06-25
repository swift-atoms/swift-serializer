//
//  Serializer.Always.swift
//  swift-serializer-primitives
//
//  Always-succeeding serializer.
//

extension Serializer {
    /// A serializer that always succeeds without writing to the buffer.
    ///
    /// ``Serializer/Always`` is useful as an identity element and for
    /// accepting values that produce no buffer output.
    public struct Always<Buffer, Output> {
        /// Creates an always-succeeding serializer.
        @inlinable
        public init() {}
    }
}

extension Serializer.Always: Serializer.`Protocol` {
    /// This serializer cannot fail.
    public typealias Failure = Never

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Accepts the value and returns without writing to the buffer.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) {
        // Always succeeds without consuming/producing buffer content
    }
}
