public import Serializer

extension Serializer {

    public struct Witness<
        Output: ~Copyable & ~Escapable,
        Buffer: ~Copyable & ~Escapable,
        Failure: Swift.Error
    >: Serializer.`Protocol` {

        public var _serialize: (borrowing Output, inout Buffer) throws(Failure) -> Void

        @inlinable
        public init(_ serialize: @escaping (borrowing Output, inout Buffer) throws(Failure) -> Void) {
            self._serialize = serialize
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            try _serialize(output, &buffer)
        }
    }

    public typealias Pure<Output, Buffer> = Witness<Output, Buffer, Never>
    where Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable
}
