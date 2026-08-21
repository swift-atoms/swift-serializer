extension Serializer {

    public struct Map<Upstream: Serializer.`Protocol`, NewOutput> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform: (NewOutput) -> Upstream.Output

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (NewOutput) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Serializer.Map: Serializer.`Protocol` {

    public typealias Buffer = Upstream.Buffer

    public typealias Failure = Upstream.Failure

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: NewOutput, into buffer: inout Buffer) throws(Failure) {
        try upstream.serialize(transform(output), into: &buffer)
    }
}
