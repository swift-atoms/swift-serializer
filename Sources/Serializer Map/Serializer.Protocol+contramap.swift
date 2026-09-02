import Either
public import Serializer

extension Serializer.`Protocol`
where
    Output: ~Copyable & Escapable,
    Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public func contramap<NewOutput: ~Copyable & ~Escapable>(
        _ transform: @escaping (borrowing NewOutput) -> Output
    ) -> Serializer.Map<Self, NewOutput> {
        .init(upstream: self, transform: transform)
    }

    @inlinable
    public func contramap<NewOutput: ~Copyable & ~Escapable, E: Swift.Error>(
        _ transform: @escaping (borrowing NewOutput) throws(E) -> Output
    ) -> Serializer.Map<Self, NewOutput>.Throwing<E> {
        .init(upstream: self, transform: transform)
    }
}
