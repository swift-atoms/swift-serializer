extension Serializer.`Protocol` {

    @inlinable
    public func filter(
        _ predicate: Predicate<Output>
    ) -> Serializer.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }

    @inlinable
    public func filter(
        _ predicate: @escaping (Output) -> Bool
    ) -> Serializer.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }
}
