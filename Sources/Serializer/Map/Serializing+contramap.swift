#if Map
public import Map
public import Either

extension Serializing
where Self: ~Copyable, Output: ~Copyable & Escapable, Buffer: ~Copyable & ~Escapable {
    @inlinable
    public consuming func contramap<NewOutput: ~Copyable & ~Escapable>(
        _ transform: @escaping (borrowing NewOutput) -> Output
    ) -> Map<NewOutput, Output, Failure>.Serializer<Self> {
        .init(upstream: self, transform: { value throws(Failure) in transform(value) }, failure: { $0 })
    }

    @inlinable
    @_disfavoredOverload
    public consuming func contramap<NewOutput: ~Copyable & ~Escapable, E: Swift.Error>(
        _ transform: @escaping (borrowing NewOutput) throws(E) -> Output
    ) -> Map<NewOutput, Output, Either<Failure, E>>.Serializer<Self> {
        .init(upstream: self, transform: { value throws(Either<Failure, E>) in
            do throws(E) { return try transform(value) } catch { throw .right(error) }
        }, failure: { .left($0) })
    }
}

extension Serializing
where Self: ~Copyable, Output: ~Copyable & Escapable, Buffer: ~Copyable & ~Escapable, Failure == Never {
    @inlinable
    public consuming func contramap<NewOutput: ~Copyable & ~Escapable, E: Swift.Error>(
        _ transform: @escaping (borrowing NewOutput) throws(E) -> Output
    ) -> Map<NewOutput, Output, E>.Serializer<Self> {
        .init(upstream: self, transform: transform, failure: { $0 })
    }
}
#endif
