#if Map
public import Map

extension Map where Source: ~Copyable & ~Escapable, Target: ~Copyable & Escapable {
    /// A serialization contramap borrows its source. The underlying Map algebra's
    /// consuming arrow is deliberately not used to project a borrowed value.
    public struct Serializer<Upstream: Serializing & ~Copyable>: Serializing, ~Copyable
    where Upstream.Output: ~Copyable & Escapable, Upstream.Buffer: ~Copyable & ~Escapable,
          Upstream.Output == Target {
        public typealias Output = Source
        public typealias Buffer = Upstream.Buffer
        public let upstream: Upstream
        public let transform: (borrowing Source) throws(Failure) -> Target
        public let failure: (Upstream.Failure) -> Failure

        @inlinable
        public init(upstream: consuming Upstream,
                    transform: @escaping (borrowing Source) throws(Failure) -> Target,
                    failure: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = transform
            self.failure = failure
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Source, into buffer: inout Buffer) throws(Failure) {
            let value = try transform(output)
            do throws(Upstream.Failure) {
                try upstream.serialize(value, into: &buffer)
            } catch {
                throw failure(error)
            }
        }
    }
}

extension Map.Serializer: Copyable
where Source: ~Copyable & ~Escapable, Target: ~Copyable & Escapable,
      Upstream: Serializing<Upstream.Output, Upstream.Buffer, Upstream.Failure> & Copyable,
      Upstream.Output: ~Copyable & Escapable, Upstream.Buffer: ~Copyable & ~Escapable {}
#endif
