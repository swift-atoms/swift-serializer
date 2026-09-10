#if Map
public import Map
extension Serializing
where Self: ~Copyable, Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {
    /// Maps only failures; partial buffer writes remain visible.
    @inlinable
    public consuming func mapFailure<E: Swift.Error>(
        _ transform: @escaping (Failure) -> E
    ) -> Map<Failure, E, Never>.Error.Serializer<Self> {
        Map<Failure, E, Never>(transform).errorSerializer(self)
    }
}
#endif
