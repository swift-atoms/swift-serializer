extension Serialization.Serializing {
    /// Witness for serializing a value to a complete representation.
    ///
    /// This is the canonical witness type for transformations that produce
    /// a complete representation from a value. For buffer-based serialization
    /// that appends to existing buffers, use `Serializing.Buffer` instead.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let jsonSerializer: Serialization.Serializing.Value<User, String, Void, Never> = .init { user, _ in
    ///     "{\"name\": \"\(user.name)\"}"
    /// }
    /// let json = try jsonSerializer.call(user)
    /// ```
    public struct Value<Output, Representation, Context, Failure: Swift.Error>: Sendable {
        public let call: @Sendable (_ value: Output, _ context: Context) throws(Failure) -> Representation

        @inlinable
        public init(call: @escaping @Sendable (_ value: Output, _ context: Context) throws(Failure) -> Representation) {
            self.call = call
        }
    }
}
