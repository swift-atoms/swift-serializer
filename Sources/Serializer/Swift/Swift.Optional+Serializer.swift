extension Swift.Optional where Wrapped: Serializing & ~Copyable,
    Wrapped.Output: ~Copyable & Escapable, Wrapped.Buffer: ~Copyable & ~Escapable {
    /// Serializes optional values using a required element serializer.
    /// A present value propagates failure; absence emits nothing.
    public struct Serializer: Serializing, ~Copyable {
        public typealias Output = Wrapped.Output?
        public typealias Buffer = Wrapped.Buffer
        public typealias Failure = Wrapped.Failure
        public let wrapped: Wrapped
        @inlinable public init(_ wrapped: consuming Wrapped) { self.wrapped = wrapped }
        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            switch output {
            case .some(let value): try wrapped.serialize(value, into: &buffer)
            case .none: return
            }
        }
    }
}

extension Swift.Optional.Serializer: Copyable
where Wrapped: Serializing<Wrapped.Output, Wrapped.Buffer, Wrapped.Failure> & Copyable,
      Wrapped.Output: ~Copyable & Escapable, Wrapped.Buffer: ~Copyable & ~Escapable {}
