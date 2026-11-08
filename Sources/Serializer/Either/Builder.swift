#if Either
    public import Serializer_Core
    public import Either

    extension Serializer::Builder where Buffer: ~Copyable & ~Escapable {
        @inlinable
        public static func buildExpression<L: Serializing & ~Copyable, R: Serializing & ~Copyable>(
            _ either: consuming Either<L, R>
        ) -> Either<L, R>.Serializer
        where
            L.Buffer == Buffer,
            R.Buffer == Buffer,
            L.Output == R.Output,
            L.Buffer: ~Copyable & ~Escapable,
            R.Buffer: ~Copyable & ~Escapable,
            L.Output: ~Copyable & ~Escapable,
            R.Output: ~Copyable & ~Escapable
        {
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

#if Lazy
    public import Serializer_Core
    public import Lazy
    public import Either
    extension Builder where Buffer: ~Copyable & ~Escapable {
        @inlinable
        public static func buildExpression<S: Serializing & ~Copyable, E: Swift::Error>(
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

#if Pair
    public import Serializer_Core
    public import Pair
    public import Either

    extension Builder where Buffer: ~Copyable & ~Escapable {
        @inlinable
        @_disfavoredOverload
        public static func buildPartialBlock<A: Serializing & ~Copyable, N: Serializing & ~Copyable>(
            accumulated: consuming A,
            next: consuming N
        ) -> Pair<A, N>.Serializer<Either<A.Failure, N.Failure>>
        where
            A.Buffer: ~Copyable & ~Escapable,
            N.Buffer: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable,
            N.Output: ~Copyable & Escapable,
            A.Buffer == Buffer,
            N.Buffer == Buffer
        {
            Pair(accumulated, next).serializer()
        }

        @inlinable
        public static func buildPartialBlock<A: Serializing & ~Copyable, N: Serializing & ~Copyable>(
            accumulated: consuming A,
            next: consuming N
        ) -> Pair<A, N>.Serializer<A.Failure>
        where
            A.Buffer: ~Copyable & ~Escapable,
            N.Buffer: ~Copyable & ~Escapable,
            A.Output: ~Copyable & Escapable,
            N.Output: ~Copyable & Escapable,
            A.Buffer == Buffer,
            N.Buffer == Buffer,
            A.Failure == N.Failure
        {
            Pair(accumulated, next).serializer()
        }
    }
#endif
