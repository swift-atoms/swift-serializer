extension Serializer {

    @resultBuilder
    public struct Builder<B> {}
}

extension Serializer.Builder {

    @inlinable
    public static func buildExpression<S: Serializer.`Protocol`>(
        _ serializer: S
    ) -> S where S.Buffer == B {
        serializer
    }

    @inlinable
    public static func buildBlock<S: Serializer.`Protocol`>(
        _ serializer: S
    ) -> S where S.Buffer == B {
        serializer
    }

    @inlinable
    public static func buildPartialBlock<S: Serializer.`Protocol`>(
        first: S
    ) -> S where S.Buffer == B {
        first
    }
}
