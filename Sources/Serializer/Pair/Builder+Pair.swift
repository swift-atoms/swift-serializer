#if Pair
public import Pair
public import Either

extension Builder where Buffer: ~Copyable & ~Escapable {
    @inlinable
    @_disfavoredOverload
    public static func buildPartialBlock<A: Serializing & ~Copyable, N: Serializing & ~Copyable>(
        accumulated: consuming A, next: consuming N
    ) -> Pair<A, N>.Serializer<Either<A.Failure, N.Failure>>
    where A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable,
          A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
          A.Buffer == Buffer, N.Buffer == Buffer {
        Pair(accumulated, next).serializer()
    }

    @inlinable
    public static func buildPartialBlock<A: Serializing & ~Copyable, N: Serializing & ~Copyable>(
        accumulated: consuming A, next: consuming N
    ) -> Pair<A, N>.Serializer<A.Failure>
    where A.Buffer: ~Copyable & ~Escapable, N.Buffer: ~Copyable & ~Escapable,
          A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable,
          A.Buffer == Buffer, N.Buffer == Buffer, A.Failure == N.Failure {
        Pair(accumulated, next).serializer()
    }
}
#endif
