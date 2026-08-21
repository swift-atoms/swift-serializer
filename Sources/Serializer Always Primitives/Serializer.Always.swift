extension Serializer {

    public struct Always<Buffer, Output> {

        @inlinable
        public init() {}
    }
}

extension Serializer.Always: Serializer.`Protocol` {

    public typealias Failure = Never

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) {

    }
}
