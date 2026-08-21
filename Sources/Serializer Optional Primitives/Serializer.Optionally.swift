extension Serializer {

    public struct Optionally<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        internal let wrapped: Wrapped

        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

extension Serializer.Optionally: Serializer.`Protocol` {

    public typealias Output = Wrapped.Output?

    public typealias Buffer = Wrapped.Buffer

    public typealias Failure = Wrapped.Failure

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
