import Either
import Serializer
import Serializer_Map
import Testing

@Suite
struct `Serializer.Map` {

    @Test
    func `contramap transforms the new output before delegating`() {
        let mapped = Digit().contramap { (text: borrowing String) -> UInt8 in UInt8(text.count) }
        var buffer: [UInt8] = []
        mapped.serialize("hello", into: &buffer)
        #expect(buffer == [5])
    }

    @Test
    func `a total contramap introduces no failure`() {
        let mapped = NonZero().contramap { (text: borrowing String) -> UInt8 in UInt8(text.count) }
        requireFailure(mapped, Rejection.self)
    }

    @Test
    func `a throwing contramap nests the transform failure on the right`() {
        let mapped = NonZero().contramap { (text: borrowing String) throws(Empty) -> UInt8 in
            guard !text.isEmpty else { throw Empty() }
            return UInt8(text.count)
        }
        requireFailure(mapped, Either<Rejection, Empty>.self)

        var buffer: [UInt8] = []
        #expect(throws: Either<Rejection, Empty>.right(Empty())) {
            try mapped.serialize("", into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `a throwing contramap keeps the upstream failure on the left`() {
        let mapped = NonZero().contramap { (value: borrowing Int) throws(Empty) -> UInt8 in
            UInt8(truncatingIfNeeded: copy value)
        }
        var buffer: [UInt8] = []
        #expect(throws: Either<Rejection, Empty>.left(.zero)) {
            try mapped.serialize(0, into: &buffer)
        }
    }

    @Test
    func `contramap borrows a noncopyable new output`() {
        let mapped = Digit().contramap { (token: borrowing Token) -> UInt8 in token.value }
        var buffer: [UInt8] = []
        let token = Token(value: 8)
        mapped.serialize(token, into: &buffer)
        #expect(buffer == [8])
        #expect(token.value == 8)
    }
}

private func requireFailure<S: Serializer.`Protocol`, Failure: Swift.Error>(
    _: borrowing S,
    _: Failure.Type
) where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Failure == Failure {}

private struct Empty: Swift.Error, Equatable {}

private struct Token: ~Copyable {
    let value: UInt8
}

private enum Rejection: Swift.Error, Equatable {
    case zero
}

private struct Digit: Serializer.`Protocol` {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) {
        buffer.append(output)
    }
}

private struct NonZero: Serializer.`Protocol` {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(Rejection) {
        guard output != 0 else { throw .zero }
        buffer.append(output)
    }
}
