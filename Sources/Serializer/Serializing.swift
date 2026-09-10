/// Serializes a borrowed value into an independently represented mutable buffer.
public protocol Serializing<Output, Buffer, Failure>: ~Copyable {
    associatedtype Output: ~Copyable & ~Escapable
    associatedtype Buffer: ~Copyable & ~Escapable
    associatedtype Failure: Swift.Error = Never
    associatedtype Body: ~Copyable = Never
    
    @Builder<Buffer>
    var body: Body { borrowing get }
    
    borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure)
}

extension Serializing
where Self: ~Copyable, Output: ~Copyable & ~Escapable,
      Buffer: ~Copyable & ~Escapable, Body == Never {
    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf serializer: implement serialize(_:into:) directly")
        }
    }
}

extension Serializing
where Self: ~Copyable, Output: ~Copyable & ~Escapable,
      Buffer: ~Copyable & ~Escapable,
      Body: Serializing & ~Copyable,
      Body.Output: ~Copyable & ~Escapable,
      Body.Buffer: ~Copyable & ~Escapable {
    @inlinable
    public borrowing func serialize(_ output: borrowing Body.Output, into buffer: inout Body.Buffer) throws(Body.Failure) {
        try body.serialize(output, into: &buffer)
    }
}

extension Serializing
where Self: ~Copyable,
      Output: ~Copyable & ~Escapable,
      Buffer: RangeReplaceableCollection
{    
    @inlinable
    public borrowing func serialize(_ output: borrowing Output) throws(Failure) -> Buffer {
        var buffer = Buffer()
        try serialize(output, into: &buffer)
        return buffer
    }
}
