extension Serializer.Builder {

    @inlinable
    public static func buildBlock<P0: Serializer.`Protocol`, P1: Serializer.`Protocol`>(
        _ p0: P0,
        _ p1: P1
    ) -> Serializer.Sequence.Two<P0, P1>
    where
        P0.Buffer == B,
        P1.Buffer == B,
        P0.Output == P1.Output
    {
        Serializer.Sequence.Two(p0, p1)
    }
}

extension Serializer.Builder {

    @inlinable
    public static func buildPartialBlock<
        Accumulated: Serializer.`Protocol`,
        Next: Serializer.`Protocol`
    >(
        accumulated: Accumulated,
        next: Next
    ) -> Serializer.Sequence.Two<Accumulated, Next>
    where
        Accumulated.Buffer == B,
        Next.Buffer == B,
        Accumulated.Output == Next.Output
    {
        Serializer.Sequence.Two(accumulated, next)
    }
}
