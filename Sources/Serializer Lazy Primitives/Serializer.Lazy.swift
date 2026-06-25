//
//  Serializer.Lazy.swift
//  swift-serializer-primitives
//
//  Lazy serializer for recursive formats.
//

extension Serializer {
    /// A serializer that defers construction until serialize time.
    ///
    /// ``Serializer/Lazy`` enables recursive formats by breaking the cycle in
    /// type definitions. The serializer is built fresh on each `serialize` call.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Recursive expression serializer
    /// func makeExpr() -> some Serializer.`Protocol`<Expr, [UInt8], some Error> {
    ///     // ...
    ///     Lazy { makeExpr() }  // Recursive reference
    ///     // ...
    /// }
    /// ```
    ///
    /// ## Performance Note
    ///
    /// The closure is called on every `serialize` invocation, creating a
    /// new serializer instance each time. For hot paths, consider caching
    /// the serializer externally if profiling shows this as a bottleneck.
    public struct Lazy<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        internal let build: () -> Wrapped

        /// Creates a lazy serializer from an autoclosure.
        ///
        /// - Parameter build: An expression that creates the serializer.
        @inlinable
        public init(_ build: @escaping @autoclosure () -> Wrapped) {
            self.build = build
        }

        /// Creates a lazy serializer from a closure.
        ///
        /// - Parameter build: A closure that creates the serializer.
        @inlinable
        public init(_ build: @escaping () -> Wrapped) {
            self.build = build
        }
    }
}

// MARK: - Serializer Conformance

extension Serializer.Lazy: Serializer.`Protocol` {
    /// The output type is inherited from the wrapped serializer.
    public typealias Output = Wrapped.Output

    /// The buffer type is inherited from the wrapped serializer.
    public typealias Buffer = Wrapped.Buffer

    /// The failure type is inherited from the wrapped serializer.
    public typealias Failure = Wrapped.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Builds the wrapped serializer fresh and delegates serialization to it.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try build().serialize(output, into: &buffer)
    }
}
