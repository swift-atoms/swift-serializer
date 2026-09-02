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

    @Test
    func `error map hands the exact upstream failure to the transform`() {
        let serializer = NonZero().error.map { (failure: Rejection) -> Downstream in
            failure == .zero ? .rejected : .other
        }
        var buffer: [UInt8] = []
        #expect(throws: Downstream.rejected) {
            try serializer.serialize(0, into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `error map composes with a second error map`() throws(any Swift.Error) {
        let serializer = NonZero()
            .error.map { (_: Rejection) -> Downstream in .rejected }
            .error.map { (_: Downstream) -> Rejection in .zero }
        var buffer: [UInt8] = []
        #expect(throws: Rejection.zero) {
            try serializer.serialize(0, into: &buffer)
        }
        try serializer.serialize(9, into: &buffer)
        #expect(buffer == [9])
        requireFailure(serializer, Rejection.self)
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
    case other
}

private struct NonZero: Serializer.`Protocol` {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(Rejection) {
        guard output != 0 else { throw .zero }
        buffer.append(output)
    }
}
