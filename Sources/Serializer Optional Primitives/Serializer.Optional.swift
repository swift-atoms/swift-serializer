extension Serializer {

    public struct Optional<Wrapped: Serializer.`Protocol`> {
        @usableFromInline
        let wrapped: Wrapped?

        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }
    }
}

extension Serializer.Optional: Serializer.`Protocol` {

    public typealias Output = Wrapped.Output?

    public typealias Buffer = Wrapped.Buffer

    public typealias Failure = Wrapped.Failure

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard let wrapped, let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
