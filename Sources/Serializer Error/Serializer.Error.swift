public import Serializer

extension Serializer {

    public enum Error {}
}

extension Serializer.Error {

    public struct Transform<Upstream: Serializer.`Protocol`>
    where
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        package init(_ upstream: Upstream) {
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
