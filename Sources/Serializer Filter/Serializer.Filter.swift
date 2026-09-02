extension Serializer {

    public struct Filter<Upstream: Serializer.`Protocol`> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let predicate: Predicate<Upstream.Output>

        @inlinable
        public init(
            upstream: Upstream,
            predicate: Predicate<Upstream.Output>
        ) {
            self.upstream = upstream
            self.predicate = predicate
        }

        @inlinable
        public init(
            upstream: Upstream,
            predicate: @escaping (Upstream.Output) -> Bool
        ) {
            self.init(upstream: upstream, predicate: Predicate(predicate))
        }
    }
}

extension Serializer.Filter: Serializer.`Protocol` {

    public typealias Output = Upstream.Output

    public typealias Buffer = Upstream.Buffer

    public typealias Failure = Either<Upstream.Failure, Serializer.Filter<Upstream>.Error>

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        guard predicate(output) else {
            throw .right(.validationFailed(value: "\(output)", reason: "filter predicate"))
        }
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
