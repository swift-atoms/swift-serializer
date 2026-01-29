extension Serialization.Parsing.Prefix {
    /// The result of prefix parsing: a value and the count of elements consumed.
    ///
    /// By returning count instead of a remainder, we avoid baking any specific
    /// view type into the witness. The caller can derive the remainder in their
    /// preferred representation type using the count.
    ///
    /// The `Count` type parameter allows typed counts (e.g., `Index<UInt8>.Count`)
    /// for type-safe arithmetic, while still supporting `Int` where needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = try parser.call(bytes)
    /// print("Parsed: \(result.value)")
    /// print("Consumed: \(result.count) bytes")
    /// ```
    public struct Result<Output: Sendable, Count: Sendable>: Sendable {
        /// The parsed value.
        public let value: Output

        /// The number of elements consumed from the input.
        public let count: Count

        @inlinable
        public init(value: Output, count: Count) {
            self.value = value
            self.count = count
        }
    }
}
