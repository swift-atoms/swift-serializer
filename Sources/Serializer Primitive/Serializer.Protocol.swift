//
//  Serializer.Protocol.swift
//  swift-serializer-primitives
//
//  Core Serializer protocol definition.
//

extension Serializer {
    /// A type that can serialize a value by appending to a buffer.
    ///
    /// `Serializer.Protocol` is the canonical protocol for one-way,
    /// machine-readable serialization with O(1) amortized append performance.
    ///
    /// ## Declarative Composition
    ///
    /// Domain serializers can declare their format via ``body-swift.property``,
    /// composing existing serializers with output mapping:
    ///
    /// ```swift
    /// struct MediaTypeSerializer: Serializer.`Protocol` {
    ///     typealias Output = MediaType
    ///     typealias Buffer = [UInt8]
    ///     typealias Failure = Never
    ///
    ///     var body: some Serializer.`Protocol`<MediaType, [UInt8], Never> {
    ///         ...
    ///     }
    /// }
    /// ```
    ///
    /// The default ``serialize(_:into:)`` delegates to ``body-swift.property``.
    /// Leaf serializers implement ``serialize(_:into:)`` directly; their ``Body``
    /// is `Never`.
    public protocol `Protocol`<Output, Buffer, Failure>: ~Copyable {
        /// The type of value this serializer accepts.
        associatedtype Output

        /// The buffer type this serializer writes to.
        associatedtype Buffer

        /// The error type this serializer can throw.
        ///
        /// Defaults to `Never` for infallible serializers; conformers MAY
        /// override to a domain-specific `Swift.Error`-conforming type.
        associatedtype Failure: Swift.Error = Never

        /// The type of the composed serializer body, or `Never` for leaf serializers.
        associatedtype Body: ~Copyable

        /// The composed serializer body.
        ///
        /// Override this property to declare a serializer declaratively.
        /// Leaf serializers that implement ``serialize(_:into:)`` directly do not
        /// override this property — the default returns `Never`.
        @Serializer.Builder<Buffer>
        var body: Body { borrowing get }

        /// Serializes a value by appending to the buffer.
        ///
        /// On success, appends the serialized representation to buffer.
        /// On failure, throws an error. The buffer state after failure is undefined.
        ///
        /// - Parameters:
        ///   - output: The value to serialize.
        ///   - buffer: The buffer to append to.
        /// - Throws: `Failure` if serialization fails.
        borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure)
    }
}

// MARK: - Leaf Serializer Default (Body == Never)

extension Serializer.`Protocol` where Self: ~Copyable, Body == Never {
    /// Leaf serializers do not have a body.
    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf serializer — implement serialize(_:into:) directly")
        }
    }
}

// MARK: - Declarative Serializer Default (Body: Serializer.Protocol)

extension Serializer.`Protocol`
where
    Self: ~Copyable,
    // reason: `Body: Serializer.Protocol` constrains Body to the protocol; `Body: Self` would
    // over-constrain Body to the exact conforming type. Autocorrect would change the semantics.
    // swiftlint:disable:next prefer_self_in_static_references
    Body: Serializer.`Protocol`,
    Body.Output == Output,
    Body.Buffer == Buffer,
    Body.Failure == Failure
{
    /// Default serialize implementation that delegates to ``body-swift.property``.
    @inlinable
    public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}

// MARK: - Convenience Extensions

extension Serializer.`Protocol` where Self: ~Copyable, Buffer: RangeReplaceableCollection {
    /// Serializes a value, returning the constructed buffer.
    ///
    /// - Parameter output: The value to serialize.
    /// - Returns: The serialized buffer.
    /// - Throws: `Failure` if serialization fails.
    @inlinable
    public borrowing func serialize(_ output: Output) throws(Failure) -> Buffer {
        var buffer = Buffer()
        try serialize(output, into: &buffer)
        return buffer
    }
}

extension Serializer.`Protocol` where Self: ~Copyable, Failure == Never, Buffer: RangeReplaceableCollection {
    /// Serializes a value, returning the constructed buffer.
    ///
    /// Infallible version for serializers that cannot fail.
    ///
    /// - Parameter output: The value to serialize.
    /// - Returns: The serialized buffer.
    @inlinable
    public borrowing func serialize(_ output: Output) -> Buffer {
        var buffer = Buffer()
        serialize(output, into: &buffer)
        return buffer
    }
}
