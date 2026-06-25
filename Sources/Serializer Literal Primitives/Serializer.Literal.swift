//
//  Serializer.Literal.swift
//  swift-serializer-primitives
//
//  Literal byte sequence emission.
//

public import Byte_Primitives

extension Serializer {
    /// A serializer that emits a fixed byte sequence.
    ///
    /// ``Serializer/Literal`` appends exact bytes to the buffer. It accepts
    /// `Void` output, making it ideal for delimiters and keywords.
    public struct Literal<Buffer: RangeReplaceableCollection>
    where Buffer.Element == Byte {
        @usableFromInline
        let bytes: [Byte]

        /// Creates a literal serializer from a sequence of bytes.
        ///
        /// - Parameter bytes: The exact bytes to emit on each serialize call.
        @inlinable
        public init(_ bytes: some Swift.Sequence<some Byte.`Protocol`>) {
            self.bytes = Swift.Array(bytes.lazy.map(\.byte))
        }

        /// Creates a literal serializer from the UTF-8 bytes of a static string.
        ///
        /// - Parameter string: The static string whose UTF-8 bytes are emitted.
        @inlinable
        public init(_ string: StaticString) {
            self.bytes = unsafe Swift.Array(
                string.utf8Start.withMemoryRebound(to: UInt8.self, capacity: string.utf8CodeUnitCount) {
                    unsafe UnsafeBufferPointer(start: $0, count: string.utf8CodeUnitCount)
                }.lazy.map(Byte.init)
            )
        }
    }
}

extension Serializer.Literal: Serializer.`Protocol` {
    /// This serializer accepts no input value.
    public typealias Output = Void

    /// This serializer cannot fail.
    public typealias Failure = Never

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Appends the fixed byte sequence to the buffer.
    @inlinable
    public func serialize(_ output: Void, into buffer: inout Buffer) {
        buffer.append(contentsOf: bytes)
    }
}

extension Serializer.Literal: ExpressibleByStringLiteral {
    /// Creates a literal serializer from the UTF-8 bytes of a string literal.
    @inlinable
    public init(stringLiteral value: String) {
        self.bytes = value.utf8.map(Byte.init)
    }
}

extension Serializer.Literal: ExpressibleByUnicodeScalarLiteral {
    /// Creates a literal serializer from the UTF-8 bytes of a Unicode scalar literal.
    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self.bytes = String(value).utf8.map(Byte.init)
    }
}

extension Serializer.Literal: ExpressibleByExtendedGraphemeClusterLiteral {
    /// Creates a literal serializer from the UTF-8 bytes of a grapheme-cluster literal.
    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.bytes = String(value).utf8.map(Byte.init)
    }
}
