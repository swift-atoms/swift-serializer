extension Serializer.`Protocol` {
    /// Filters the serializer's input using a predicate.
    ///
    /// If the predicate returns false, serialization fails before delegating to
    /// the upstream serializer.
    ///
    /// - Parameter predicate: A function that validates the input.
    /// - Returns: A serializer that fails if the predicate is false.
    @inlinable
    public func filter(
        _ predicate: @escaping (Output) -> Bool
    ) -> Serializer.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }
}
