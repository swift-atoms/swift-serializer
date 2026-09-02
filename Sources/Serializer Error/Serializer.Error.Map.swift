public import Serializer

extension Serializer.Error {

    public struct Map<Upstream: Serializer.`Protocol`, NewFailure: Swift.Error>: Serializer.`Protocol`
    where
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Buffer: ~Copyable & ~Escapable
    {
        public typealias Output = Upstream.Output

        public typealias Buffer = Upstream.Buffer

        public typealias Failure = NewFailure

        public let upstream: Upstream

        public let transform: (Upstream.Failure) -> NewFailure

        @inlinable
        package init(
            _ upstream: Upstream,
            transform: @escaping (Upstream.Failure) -> NewFailure
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            do throws(Upstream.Failure) {
                try upstream.serialize(output, into: &buffer)
            } catch {
                throw transform(error)
            }
        }
    }
}

extension Serializer.Error.Transform
where
    Upstream.Output: ~Copyable & ~Escapable,
    Upstream.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public func map<NewFailure: Swift.Error>(
        _ transform: @escaping (Upstream.Failure) -> NewFailure
    ) -> Serializer.Error.Map<Upstream, NewFailure> {
        Serializer.Error.Map(upstream, transform: transform)
    }
}
