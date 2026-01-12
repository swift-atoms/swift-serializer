extension Serialization.Serializing {
    /// Witness for appending serialized output to a buffer.
    ///
    /// This is the canonical witness type for allocation-avoiding serialization
    /// that appends to an existing buffer rather than returning a new allocation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let byteSerializer: Serialization.Serializing.Buffer<UInt32, UInt8, Void> = .init { value, _, buffer in
    ///     buffer.append(UInt8(truncatingIfNeeded: value >> 24))
    ///     buffer.append(UInt8(truncatingIfNeeded: value >> 16))
    ///     buffer.append(UInt8(truncatingIfNeeded: value >> 8))
    ///     buffer.append(UInt8(truncatingIfNeeded: value))
    /// }
    ///
    /// var bytes: [UInt8] = []
    /// byteSerializer.call(0xDEADBEEF, into: &bytes)
    /// // bytes == [0xDE, 0xAD, 0xBE, 0xEF]
    /// ```
    public struct Buffer<Output: Sendable, Element: Sendable, Context: Sendable>: Sendable {
        public let call: @Sendable (_ value: Output, _ context: Context, _ buffer: inout [Element]) -> Void

        @inlinable
        public init(call: @escaping @Sendable (_ value: Output, _ context: Context, _ buffer: inout [Element]) -> Void) {
            self.call = call
        }
    }
}
