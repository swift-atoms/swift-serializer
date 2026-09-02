public import Byte

extension Serializer {

    public struct Literal<Buffer: RangeReplaceableCollection>
    where Buffer.Element == Byte {
        @usableFromInline
        let bytes: [Byte]

        @inlinable
        public init(_ bytes: some Swift.Sequence<Byte>) {
            self.bytes = Swift.Array(bytes)
        }

        @inlinable
        public init(_ string: StaticString) {
            unsafe (self.bytes = Swift.Array(
                string.utf8Start.withMemoryRebound(
                    to: UInt8.self,
                    capacity: string.utf8CodeUnitCount
                ) {
                    unsafe UnsafeBufferPointer(start: $0, count: string.utf8CodeUnitCount)
                }.lazy.map(Byte.init(bitPattern:))
            ))
        }
    }
}

extension Serializer.Literal: Serializer.`Protocol` {

    public typealias Output = Void

    public typealias Failure = Never

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Void, into buffer: inout Buffer) {
        buffer.append(contentsOf: bytes)
    }
}

extension Serializer.Literal: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: String) {
        self.bytes = value.utf8.map(Byte.init(bitPattern:))
    }
}

extension Serializer.Literal: ExpressibleByUnicodeScalarLiteral {

    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self.bytes = String(value).utf8.map(Byte.init(bitPattern:))
    }
}

extension Serializer.Literal: ExpressibleByExtendedGraphemeClusterLiteral {

    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.bytes = String(value).utf8.map(Byte.init(bitPattern:))
    }
}
