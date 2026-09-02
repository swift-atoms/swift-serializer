extension Serializer {

    public protocol `Protocol`<Output, Buffer, Failure>: ~Copyable {

        associatedtype Output

        associatedtype Buffer

        associatedtype Failure: Swift.Error = Never

        associatedtype Body: ~Copyable

        @Serializer.Builder<Buffer>
        var body: Body { borrowing get }

        borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure)
    }
}

extension Serializer.`Protocol` where Self: ~Copyable, Body == Never {

    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf serializer — implement serialize(_:into:) directly")
        }
    }
}

extension Serializer.`Protocol`
where
    Self: ~Copyable,

    Body: Serializer.`Protocol`,
    Body.Output == Output,
    Body.Buffer == Buffer,
    Body.Failure == Failure
{

    @inlinable
    public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}
