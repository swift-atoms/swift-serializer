extension Serialization.Parsing {
    /// Witness for parsing a complete representation into a value.
    ///
    /// This is the canonical witness type for transformations that consume
    /// an entire representation to produce a value. For parsing that consumes
    /// only a prefix, use `Parsing.Prefix.Witness` instead.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let jsonParser: Serialization.Parsing.Whole<User, String, Void, ParseError> = .init { json, _ in
    ///     try parseJSON(json)
    /// }
    /// let user = try jsonParser.call(jsonString)
    /// ```
    public struct Whole<Output, Representation, Context, Failure: Swift.Error>: Sendable {
        public let call: @Sendable (_ representation: Representation, _ context: Context) throws(Failure) -> Output

        @inlinable
        public init(call: @escaping @Sendable (_ representation: Representation, _ context: Context) throws(Failure) -> Output) {
            self.call = call
        }
    }
}
