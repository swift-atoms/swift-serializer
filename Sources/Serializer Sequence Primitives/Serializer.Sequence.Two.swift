extension Serializer.Sequence {

    public struct Two<P0: Serializer.`Protocol`, P1: Serializer.`Protocol`>
    where
        P0.Output == P1.Output,
        P0.Buffer == P1.Buffer
    {
        @usableFromInline
        internal let p0: P0

        @usableFromInline
        internal let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Serializer.Sequence.Two: Serializer.`Protocol` {

    public typealias Output = P0.Output

    public typealias Buffer = P0.Buffer

    public typealias Failure = Either<P0.Failure, P1.Failure>

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
