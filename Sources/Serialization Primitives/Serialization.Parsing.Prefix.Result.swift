extension Serialization.Parsing.Prefix {
    /// The result of prefix parsing: a value and the count of elements consumed.
    ///
    /// By returning count instead of a remainder, we avoid baking any specific
    /// view type into the witness. The caller can derive the remainder in their
    /// preferred representation type using the count.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = try parser.call(bytes)
    /// print("Parsed: \(result.value)")
    /// print("Consumed: \(result.count) bytes")
    /// let remainder = bytes.dropFirst(result.count)
    /// ```
    public struct Result<Output: Sendable>: Sendable {
        /// The parsed value.
        public let value: Output

        /// The number of elements consumed from the input.
        public let count: Int

        @inlinable
        public init(value: Output, count: Int) {
            self.value = value
            self.count = count
        }
    }
}
