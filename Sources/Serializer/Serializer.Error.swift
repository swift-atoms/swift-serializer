extension Serializer {

    public enum Error {}
}

extension Serializer.Error {

    public struct Transform<Upstream: Serializer.`Protocol` & ~Copyable>: ~Copyable
    where
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        public init(_ upstream: consuming Upstream) {
            self.upstream = upstream
        }
    }
}

extension Serializer.`Protocol`
where
    Output: ~Copyable & ~Escapable,
    Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public var error: Serializer.Error.Transform<Self> {
        Serializer.Error.Transform(self)
    }
}

extension Serializer.Error.Transform: Copyable
where
    Upstream: Serializer.`Protocol`<Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{}
