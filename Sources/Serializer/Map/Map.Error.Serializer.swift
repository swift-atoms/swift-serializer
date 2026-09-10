#if Map
public import Map

extension Map.Error where Source: Swift.Error, Target: Swift.Error, Failure == Never {

    /// Maps only an upstream serializer's failure, preserving its owner.
    /// Partial writes remain visible; the buffer is not rewound.
    public struct Serializer<Upstream: Serializing & ~Copyable>: Serializing, ~Copyable
    where
        Upstream.Buffer: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Failure == Source
    {
        public typealias Buffer = Upstream.Buffer
        public typealias Output = Upstream.Output
        public typealias Failure = Target

        public let base: Map
        public let upstream: Upstream

        @inlinable
        public init(_ base: Map, _ upstream: consuming Upstream) {
            self.base = base
            self.upstream = upstream
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            do throws(Upstream.Failure) {
                try upstream.serialize(output, into: &buffer)
            } catch {
                throw base(error)
            }
        }
    }
}

extension Map where Source: Swift.Error, Target: Swift.Error, Failure == Never {

    @inlinable
    public func errorSerializer<P: Serializing & ~Copyable>(_ upstream: consuming P) -> Error.Serializer<P>
    where
        P.Buffer: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable,
        P.Failure == Source
    {
        .init(self, upstream)
    }
}

extension Map.Error.Serializer: Copyable
where
    Upstream: Serializing<Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
    Upstream.Buffer: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{}

#endif
