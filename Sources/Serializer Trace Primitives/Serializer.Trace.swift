extension Serializer {

    public struct Trace<Upstream: Serializer.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let label: String

        @usableFromInline
        let log: (String) -> Void

        @inlinable
        public init(
            _ upstream: Upstream,
            label: String,
            log: @escaping (String) -> Void = { print($0) }
        ) {
            self.upstream = upstream
            self.label = label
            self.log = log
        }
    }
}

extension Serializer.Trace: Serializer.`Protocol` {

    public typealias Output = Upstream.Output

    public typealias Buffer = Upstream.Buffer

    public typealias Failure = Upstream.Failure

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        log("[\(label)] enter")
        do throws(Upstream.Failure) {
            try upstream.serialize(output, into: &buffer)
            log("[\(label)] success: \(output)")
        } catch {
            log("[\(label)] failure: \(error)")
            throw error
        }
    }
}

extension Serializer.`Protocol` {

    @inlinable
    public func trace(
        _ label: String,
        log: @escaping (String) -> Void = { print($0) }
    ) -> Serializer.Trace<Self> {
        Serializer.Trace(self, label: label, log: log)
    }
}
