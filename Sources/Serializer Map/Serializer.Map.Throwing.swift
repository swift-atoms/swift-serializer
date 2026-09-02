public import Either
public import Serializer

extension Serializer.Map
where
    NewOutput: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    public struct Throwing<E: Swift.Error>: Serializer.`Protocol` {

        public typealias Output = NewOutput

        public typealias Buffer = Upstream.Buffer

        public typealias Failure = Either<Upstream.Failure, E>

        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (borrowing NewOutput) throws(E) -> Upstream.Output

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (borrowing NewOutput) throws(E) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing NewOutput, into buffer: inout Buffer) throws(Failure) {
            let upstreamOutput: Upstream.Output
            do throws(E) {
                upstreamOutput = try transform(output)
            } catch {
                throw .right(error)
            }
            do throws(Upstream.Failure) {
                try upstream.serialize(upstreamOutput, into: &buffer)
            } catch {
                throw .left(error)
            }
        }
    }
}
