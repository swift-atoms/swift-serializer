extension Serializer {

    public struct Fail<Buffer, Output, F: Swift.Error> {
        @usableFromInline
        let error: F

        @inlinable
        public init(_ error: F) {
            self.error = error
        }
    }
}

extension Serializer.Fail: Serializer.`Protocol` {

    public typealias Failure = F

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        throw error
    }
}
