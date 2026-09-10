#if Lazy
public import Lazy
public import Either
extension Builder where Buffer: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<S: Serializing & ~Copyable, E: Swift.Error>(
        _ lazy: Lazy<S, E>
    ) -> Lazy<S, E>.Serializer<Either<E, S.Failure>>
    where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Buffer == Buffer {
        lazy.serializer()
    }
    @inlinable
    public static func buildExpression<S: Serializing & ~Copyable>(
        _ lazy: Lazy<S, Never>
    ) -> Lazy<S, Never>.Serializer<S.Failure>
    where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Buffer == Buffer {
        lazy.serializer()
    }
}
#endif
