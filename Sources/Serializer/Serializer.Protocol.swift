extension Serializer {

    public protocol `Protocol`<Output, Buffer, Failure>: ~Copyable {

        associatedtype Output: ~Copyable & ~Escapable

        associatedtype Buffer: ~Copyable & ~Escapable

        associatedtype Failure: Swift.Error = Never

        borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure)
    }
}
