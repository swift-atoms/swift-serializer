extension Serialization.Parsing.Prefix {
    /// Witness for parsing a prefix of a representation into a value.
    ///
    /// This is the canonical witness type for transformations that consume
    /// only a prefix of the representation. Returns both the parsed value
    /// and the count of elements consumed, allowing the caller to derive
    /// the remainder in their preferred representation type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let intParser: Serialization.Parsing.Prefix.Witness<Int, [UInt8], Void, ParseError> = .init { bytes, _ in
    ///     let (value, consumed) = parseInteger(from: bytes)
    ///     return .init(value: value, count: consumed)
    /// }
    /// let result = try intParser.call(bytes)
    /// let remainder = bytes.dropFirst(result.count)
    /// ```
    public struct Witness<Output: Sendable, Representation: Sendable, Context: Sendable, Failure: Swift.Error & Sendable>: Sendable {
        public let call: @Sendable (_ representation: Representation, _ context: Context) throws(Failure) -> Result<Output>

        @inlinable
        public init(call: @escaping @Sendable (_ representation: Representation, _ context: Context) throws(Failure) -> Result<Output>) {
            self.call = call
        }
    }
}
