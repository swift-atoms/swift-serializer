extension Serializer.`Protocol` {
    /// Transforms the serializer's input using the given function.
    ///
    /// This is the contravariant `map` operation for serializers. The transform takes
    /// the new input value and produces the upstream serializer's expected output.
    ///
    /// - Parameter transform: A function to map the new input to the upstream output.
    /// - Returns: A serializer that transforms its input before delegating.
    @inlinable
    public func map<NewOutput>(
        _ transform: @escaping (NewOutput) -> Output
    ) -> Serializer.Map<Self, NewOutput> {
        .init(upstream: self, transform: transform)
    }

    /// Transforms the serializer's input using a throwing function.
    ///
    /// If the transform throws, serialization fails with that error. The resulting
    /// serializer's failure type composes both upstream and transform errors.
    ///
    /// - Parameter transform: A throwing function to map the new input to the upstream output.
    /// - Returns: A serializer that transforms its input, potentially failing.
    @inlinable
    public func tryMap<NewOutput, E: Swift.Error>(
        _ transform: @escaping (NewOutput) throws(E) -> Output
    ) -> Serializer.Map<Self, NewOutput>.Throwing<E> {
        .init(upstream: self, transform: transform)
    }
}
