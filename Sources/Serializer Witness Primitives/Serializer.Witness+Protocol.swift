//
//  Serializer.Witness+Protocol.swift
//  swift-serializer-primitives
//
//  Conformance of the closure-backed Serializer.Witness to Serializer.Protocol.
//
//  The witness struct is declared in `Serializer Namespace` so the bare
//  storage shape lives without any protocol dependency; the conformance and
//  witness methods are declared here, in the `Serializer Primitives Core`
//  target where ``Serializer/Protocol`` is defined.
//

extension Serializer.Witness: Serializer.`Protocol` {
    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes the value by invoking the stored closure.
    @inlinable
    public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try _serialize(output, &buffer)
    }
}
