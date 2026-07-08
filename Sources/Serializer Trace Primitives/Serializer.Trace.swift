//
//  Serializer.Trace.swift
//  swift-serializer-primitives
//
//  Debug tracing combinator.
//

extension Serializer {
    /// A serializer that logs entry, exit, and errors for debugging.
    ///
    /// ``Serializer/Trace`` wraps any serializer and outputs debug information
    /// without affecting serialization behavior.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let serializer = myComplexSerializer.trace("complex")
    /// // Logs:
    /// // [complex] enter
    /// // [complex] success: <output>
    /// // or
    /// // [complex] failure: <error>
    /// ```
    ///
    /// ## Custom Logger
    ///
    /// ```swift
    /// var logs: [String] = []
    /// let serializer = mySerializer.trace("test") { logs.append($0) }
    /// ```
    public struct Trace<Upstream: Serializer.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let label: String

        @usableFromInline
        let log: (String) -> Void

        /// Creates a tracing serializer.
        ///
        /// - Parameters:
        ///   - upstream: The serializer to trace.
        ///   - label: Label to identify this serializer in logs.
        ///   - log: Logging function. Defaults to `print`.
        @inlinable
        public init(
            _ upstream: Upstream,
            label: String,
            log: @escaping (String) -> Void = { print($0) }
        ) {
            self.upstream = upstream
            self.label = label
            self.log = log
        }
    }
}

// MARK: - Serializer Conformance

extension Serializer.Trace: Serializer.`Protocol` {
    /// The output type is inherited from the upstream serializer.
    public typealias Output = Upstream.Output

    /// The buffer type is inherited from the upstream serializer.
    public typealias Buffer = Upstream.Buffer

    /// The failure type is inherited from the upstream serializer.
    public typealias Failure = Upstream.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Logs entry, success, and failure around the upstream serialization.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        log("[\(label)] enter")
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
            log("[\(label)] success: \(output)")
        } catch {
            log("[\(label)] failure: \(error)")
            throw error
        }
    }
}

// MARK: - Serializer Extension

extension Serializer.`Protocol` {
    /// Wraps this serializer with debug tracing.
    ///
    /// Logs entry, success, and failure events to help debug
    /// complex serializer compositions.
    ///
    /// - Parameters:
    ///   - label: Identifier for this serializer in logs.
    ///   - log: Optional custom logging function.
    /// - Returns: A tracing wrapper around this serializer.
    @inlinable
    public func trace(
        _ label: String,
        log: @escaping (String) -> Void = { print($0) }
    ) -> Serializer.Trace<Self> {
        Serializer.Trace(self, label: label, log: log)
    }
}
