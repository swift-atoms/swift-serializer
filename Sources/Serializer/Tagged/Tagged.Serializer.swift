#if Tagged
public import Tagged

extension Tagged::Tagged
where Tag: ~Copyable & ~Escapable, Underlying: ~Copyable {
    /// Serializes the underlying value with an explicitly selected representation.
    public struct Serializer<Upstream: Serializing & ~Copyable>: Serializing, ~Copyable
    where Upstream.Output: ~Copyable & Escapable, Upstream.Output == Underlying, Upstream.Buffer: ~Copyable & ~Escapable {
        public typealias Output = Tagged::Tagged<Tag, Underlying>
        public typealias Buffer = Upstream.Buffer
        public typealias Failure = Upstream.Failure
        public let upstream: Upstream

        @inlinable public init(_ upstream: consuming Upstream) { self.upstream = upstream }

        @inlinable
        public borrowing func serialize(
            _ output: borrowing Output, into buffer: inout Buffer
        ) throws(Failure) {
            try upstream.serialize(output.underlying, into: &buffer)
        }
    }
}

extension Tagged::Tagged.Serializer: Copyable
where Tag: ~Copyable & ~Escapable, Underlying: ~Copyable,
      Upstream: Serializing<Underlying, Upstream.Buffer, Upstream.Failure> & Copyable,
      Upstream.Output: ~Copyable, Upstream.Buffer: ~Copyable & ~Escapable {}
#endif
