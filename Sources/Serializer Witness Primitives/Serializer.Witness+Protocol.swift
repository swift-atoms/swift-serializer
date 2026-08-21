extension Serializer.Witness: Serializer.`Protocol` {

    public typealias Body = Never

    @inlinable
    public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try _serialize(output, &buffer)
    }
}
