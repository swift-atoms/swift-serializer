//
//  Serializer.ASCII.Integer.Decimal.swift
//  swift-serializer-primitives
//
//  Serializes a FixedWidthInteger as ASCII decimal bytes.
//

extension Serializer.ASCII.Integer {
    /// A serializer that writes the decimal ASCII representation of a
    /// `FixedWidthInteger` into a byte buffer.
    ///
    /// Inverse of `Parser.ASCII.Integer.Decimal`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let serializer = Serializer.ASCII.Integer.Decimal<UInt16>()
    /// let bytes = serializer.serialize(8080)  // [0x38, 0x30, 0x38, 0x30]
    /// ```
    public struct Decimal<T: FixedWidthInteger>: Sendable {
        @inlinable
        public init() {}
    }
}

extension Serializer.ASCII.Integer.Decimal: Serializer.`Protocol` {
    public typealias Output = T
    public typealias Buffer = [UInt8]
    public typealias Failure = Never

    @inlinable
    public func serialize(_ output: T, into buffer: inout [UInt8]) {
        guard output != 0 else {
            buffer.append(0x30)
            return
        }

        var value = output
        let negative = T.isSigned && output < 0

        // Stack-allocated digit buffer: max 20 digits for Int64 + sign
        let start = buffer.count

        if negative {
            // Work with magnitude to avoid overflow on T.min
            var magnitude = UInt64(bitPattern: Int64(truncatingIfNeeded: output))
            magnitude = ~magnitude &+ 1
            while magnitude > 0 {
                buffer.append(UInt8(truncatingIfNeeded: magnitude % 10) &+ 0x30)
                magnitude /= 10
            }
            buffer.append(0x2D) // '-'
        } else {
            while value > 0 {
                buffer.append(UInt8(truncatingIfNeeded: value % 10) &+ 0x30)
                value /= 10
            }
        }

        // Reverse the digits we just wrote
        var lo = start
        var hi = buffer.count &- 1
        while lo < hi {
            let tmp = buffer[lo]
            buffer[lo] = buffer[hi]
            buffer[hi] = tmp
            lo &+= 1
            hi &-= 1
        }
    }
}
