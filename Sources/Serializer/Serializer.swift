public struct Serializer<
    Output: ~Copyable & ~Escapable,
    Buffer: ~Copyable & ~Escapable,
    Failure: Swift.Error
>: Serializing {
    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf serializer: implement serialize(_:into:) directly")
        }
    }

    public var _serialize: (_ output: borrowing Output, _ buffer: inout Buffer) throws(Failure) -> Void
    
    @inlinable
    public init(
        _ serialize: @escaping (_ output: borrowing Output, _ buffer: inout Buffer) throws(Failure) -> Void
    ) {
        self._serialize = serialize
    }
    
    @inlinable
    public borrowing func serialize(
        _ output: borrowing Output,
        into buffer: inout Buffer
    ) throws(Failure) {
        try _serialize(output, &buffer)
    }

    @inlinable
    public init<S: Serializing & ~Copyable>(@Builder<Buffer> _ build: () -> S)
    where
    S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable,
    S.Output == Output, S.Buffer == Buffer, S.Failure == Failure {
        let composition = build()
        self._serialize = { output, buffer throws(Failure) in
            try composition.serialize(output, into: &buffer)
        }
    }
}
