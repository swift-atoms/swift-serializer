#if Either
public import Either

extension Serializer::Builder where Buffer: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<L: Serializing & ~Copyable, R: Serializing & ~Copyable>(
        _ either: consuming Either<L, R>
    ) -> Either<L, R>.Serializer
    where L.Buffer == Buffer, R.Buffer == Buffer, L.Output == R.Output,
          L.Buffer: ~Copyable & ~Escapable, R.Buffer: ~Copyable & ~Escapable,
          L.Output: ~Copyable & ~Escapable, R.Output: ~Copyable & ~Escapable {
        .init(either)
    }


    @inlinable
    public static func buildEither<
        First: Serializing & ~Copyable,
        Second: Serializing & ~Copyable
    >(
        first: consuming First
    ) -> Either<First, Second>.Serializer
    where
        First.Buffer == Buffer,
        Second.Buffer == Buffer,
        First.Buffer: ~Copyable & ~Escapable,
        Second.Buffer: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & ~Escapable,
        Second.Output: ~Copyable & ~Escapable
    {
        .init(.left(first))
    }

    @inlinable
    public static func buildEither<
        First: Serializing & ~Copyable,
        Second: Serializing & ~Copyable
    >(
        second: consuming Second
    ) -> Either<First, Second>.Serializer
    where
        First.Buffer == Buffer,
        Second.Buffer == Buffer,
        First.Buffer: ~Copyable & ~Escapable,
        Second.Buffer: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & ~Escapable,
        Second.Output: ~Copyable & ~Escapable
    {
        .init(.right(second))
    }
}

#endif
