extension Serialization {
    /// Witness for measuring the serialized size of a value.
    ///
    /// This enables `reserveCapacity` optimizations by pre-computing the
    /// serialized size without actually performing serialization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let measuring: Serialization.Measuring<Packet, Void> = .init { packet, _ in
    ///     1 + 2 + packet.payload.count  // header + length + payload
    /// }
    ///
    /// var buffer: [UInt8] = []
    /// buffer.reserveCapacity(measuring.call(packet))
    /// serializer.call(packet, into: &buffer)
    /// ```
    public struct Measuring<Output: Sendable, Context: Sendable>: Sendable {
        public let call: @Sendable (_ value: Output, _ context: Context) -> Int

        @inlinable
        public init(call: @escaping @Sendable (_ value: Output, _ context: Context) -> Int) {
            self.call = call
        }
    }
}
