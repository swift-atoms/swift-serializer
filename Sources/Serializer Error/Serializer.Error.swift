extension Serializer {

    public enum Error {}
}

extension Serializer.Error {

    public struct Transform<Upstream: Serializer.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        package init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Serializer.`Protocol` {

    @inlinable
    public var error: Serializer.Error.Transform<Self> {
        Serializer.Error.Transform(self)
    }
}
