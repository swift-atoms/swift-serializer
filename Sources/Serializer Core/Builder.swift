@resultBuilder
public struct Builder<Buffer: ~Copyable & ~Escapable> {}

extension Builder where Buffer: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<S: Serializing & ~Copyable>(_ serializer: consuming S) -> S
    where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Buffer == Buffer {
        serializer
    }

    @inlinable
    public static func buildBlock<S: Serializing & ~Copyable>(_ serializer: consuming S) -> S
    where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Buffer == Buffer {
        serializer
    }

    @inlinable
    public static func buildPartialBlock<S: Serializing & ~Copyable>(first: consuming S) -> S
    where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Buffer == Buffer {
        first
    }
}
