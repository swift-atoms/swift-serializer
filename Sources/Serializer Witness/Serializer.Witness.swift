extension Serializer {

    public struct Witness<Output, Buffer, Failure: Swift.Error> {

        public var _serialize: (Output, inout Buffer) throws(Failure) -> Void

        @inlinable
        public init(_ serialize: @escaping (Output, inout Buffer) throws(Failure) -> Void) {
            self._serialize = serialize
        }
    }

    public typealias Pure<Output, Buffer> = Witness<Output, Buffer, Never>
}
