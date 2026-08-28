extension Serializer.Sequence {

    public struct Three<
        P0: Serializer.`Protocol`,
        P1: Serializer.`Protocol`,
        P2: Serializer.`Protocol`
    >
    where
        P0.Output == P1.Output,
        P1.Output == P2.Output,
        P0.Buffer == P1.Buffer,
        P1.Buffer == P2.Buffer
    {
        @usableFromInline
        internal let p0: P0

        @usableFromInline
        internal let p1: P1

        @usableFromInline
        internal let p2: P2

        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }
    }
}

extension Serializer.Sequence.Three: Serializer.`Protocol` {

    public typealias Output = P0.Output

    public typealias Buffer = P0.Buffer

    public typealias Failure = Either<P0.Failure, Either<P1.Failure, P2.Failure>>

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
            throw .right(.left(error))
        }
        do throws(P2.Failure) {
            try p2.serialize(output, into: &buffer)
        } catch {
            throw .right(.right(error))
        }
    }
}
