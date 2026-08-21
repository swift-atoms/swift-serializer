extension Serializer {

    public struct Lazy<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        internal let build: () -> Wrapped

        @inlinable
        public init(_ build: @escaping @autoclosure () -> Wrapped) {
            self.build = build
        }

        @inlinable
        public init(_ build: @escaping () -> Wrapped) {
            self.build = build
        }
    }
}

extension Serializer.Lazy: Serializer.`Protocol` {

    public typealias Output = Wrapped.Output

    public typealias Buffer = Wrapped.Buffer

    public typealias Failure = Wrapped.Failure

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try build().serialize(output, into: &buffer)
    }
}
