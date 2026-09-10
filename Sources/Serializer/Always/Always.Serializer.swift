#if Always
public import Always

extension Always::Always {

    @frozen

    public struct Serializer<Buffer: ~Copyable & ~Escapable>: Serializing {

        public typealias Output = Value

        public typealias Failure = Never

        public let base: Always::Always<Value>

        @inlinable
        public init(_ base: Always::Always<Value>) {
            self.base = base
        }

        @inlinable
        public init(_ value: Value) {
            self.base = Always::Always(value)
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Value, into buffer: inout Buffer) {}
    }

    @inlinable
    public func serializer<Buffer: ~Copyable & ~Escapable>() -> Serializer<Buffer> {
        .init(self)
    }
}

#endif
