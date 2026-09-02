public import Serializer

extension Serializer::Serializer {

    public struct Optional<Wrapped: Serializer::Serializer.`Protocol`> {
        @usableFromInline
        let wrapped: Wrapped?

        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }
    }
}

extension Serializer::Serializer.Optional: Serializer::Serializer.`Protocol` {

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

extension Serializer::Serializer.Builder {

    @inlinable
    public static func buildIf<S: Serializer::Serializer.`Protocol`>(
        _ serializer: S?
    ) -> Serializer::Serializer.Optional<S> where S.Buffer == B {
        .init(serializer)
    }
}
