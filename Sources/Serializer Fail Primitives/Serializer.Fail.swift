//
//  Serializer.Fail.swift
//  swift-serializer-primitives
//
//  Always-failing serializer.
//

extension Serializer {
    /// A serializer that always fails with a specified error.
    ///
    /// ``Serializer/Fail`` is useful as a fallback in error handling scenarios.
    public struct Fail<Buffer, Output, F: Swift.Error> {
        @usableFromInline
        let error: F

        /// Creates a serializer that always throws the given error.
        ///
        /// - Parameter error: The error to throw on every serialize call.
        @inlinable
        public init(_ error: F) {
            self.error = error
        }
    }
}

extension Serializer.Fail: Serializer.`Protocol` {
    /// The serializer fails with the stored error type.
    public typealias Failure = F

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Throws the stored error without writing to the buffer.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        throw error
    }
}
