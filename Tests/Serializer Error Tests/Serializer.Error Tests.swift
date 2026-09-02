import Serializer
import Serializer_Error
import Testing

@Suite
struct `Serializer.Error` {

    @Test
    func `error map rewrites the upstream failure`() {
        let serializer = NonZero().error.map { (_: Rejection) -> Downstream in .rejected }
        var buffer: [UInt8] = []
        #expect(throws: Downstream.rejected) {
            try serializer.serialize(0, into: &buffer)
        }
        requireFailure(serializer, Downstream.self)
    }

    @Test
    func `error map leaves a successful serialization untouched`() throws(any Swift.Error) {
        let serializer = NonZero().error.map { (_: Rejection) -> Downstream in .rejected }
        var buffer: [UInt8] = []
        try serializer.serialize(5, into: &buffer)
        #expect(buffer == [5])
    }
}

private func requireFailure<S: Serializer.`Protocol`, Failure: Swift.Error>(
    _: borrowing S,
    _: Failure.Type
) where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Failure == Failure {}

private enum Rejection: Swift.Error, Equatable {
    case zero
}

private enum Downstream: Swift.Error, Equatable {
    case rejected
}

private struct NonZero: Serializer.`Protocol` {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(Rejection) {
        guard output != 0 else { throw .zero }
        buffer.append(output)
    }
}
