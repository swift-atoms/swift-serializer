extension Serializer {

    public struct Map<Upstream: Serializer.`Protocol` & ~Copyable, NewOutput: ~Copyable & ~Escapable>: Serializer.`Protocol`, ~Copyable
    where
        Upstream.Output: ~Copyable & Escapable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {
        public typealias Output = NewOutput

        public typealias Buffer = Upstream.Buffer

        public typealias Failure = Upstream.Failure

        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform: (borrowing NewOutput) -> Upstream.Output

        @inlinable
        public init(
            upstream: consuming Upstream,
            transform: @escaping (borrowing NewOutput) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing NewOutput, into buffer: inout Buffer) throws(Failure) {
            try upstream.serialize(transform(output), into: &buffer)
        }
    }
}

extension Serializer.Map: Copyable
where
    Upstream: Serializer.`Protocol`<Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
    NewOutput: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{}
