extension Serializer.`Protocol` {

    @inlinable
    public func map<NewOutput>(
        _ transform: @escaping (NewOutput) -> Output
    ) -> Serializer.Map<Self, NewOutput> {
        .init(upstream: self, transform: transform)
    }

    @inlinable
    public func tryMap<NewOutput, E: Swift.Error>(
        _ transform: @escaping (NewOutput) throws(E) -> Output
    ) -> Serializer.Map<Self, NewOutput>.Throwing<E> {
        .init(upstream: self, transform: transform)
    }
}
