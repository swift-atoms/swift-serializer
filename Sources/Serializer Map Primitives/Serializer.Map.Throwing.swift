public import Either_Primitives

extension Serializer.Map {

    public struct Throwing<E: Swift.Error> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (NewOutput) throws(E) -> Upstream.Output

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (NewOutput) throws(E) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Serializer.Map.Throwing: Serializer.`Protocol` {

    public typealias Buffer = Upstream.Buffer

    public typealias Failure = Either<Upstream.Failure, E>

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: NewOutput, into buffer: inout Buffer) throws(Failure) {
        let upstreamInput: Upstream.Output
        do throws(E) {
            upstreamInput = try transform(output)
        } catch {
            throw .right(error)
        }
        do throws(Upstream.Failure) {
            try upstream.serialize(upstreamInput, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
