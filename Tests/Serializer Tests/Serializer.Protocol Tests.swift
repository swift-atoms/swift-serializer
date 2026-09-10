import Serializer
import Testing

@Suite
struct `Serializer leaves append borrowed values and preserve typed failures` {

    @Test
    func `a leaf declares only serialize`() {
        var buffer: [UInt8] = []
        Digit().serialize(7, into: &buffer)
        #expect(buffer == [7])
    }

    @Test
    func `a leaf's Failure defaults to Never`() {
        let _: Digit.Failure.Type = Never.self
    }

    @Test
    func `serialize appends in call order`() {
        var buffer: [UInt8] = [1]
        Digit().serialize(2, into: &buffer)
        Digit().serialize(3, into: &buffer)
        #expect(buffer == [1, 2, 3])
    }

    @Test
    func `a typed failure propagates through the conformance`() {
        var buffer: [UInt8] = []
        #expect(throws: Rejection.zero) {
            try NonZero().serialize(0, into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `a noncopyable output is borrowed`() {
        var buffer: [UInt8] = []
        let token = Token(value: 9)
        TokenSerializer().serialize(token, into: &buffer)
        #expect(buffer == [9])
        #expect(token.value == 9)
    }


}

private struct Digit: Serializing {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) {
        buffer.append(output)
    }
}

private enum Rejection: Swift.Error, Equatable {
    case zero
}

private struct NonZero: Serializing {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) throws(Rejection) {
        guard output != 0 else { throw .zero }
        buffer.append(output)
    }
}

private struct Token: ~Copyable {
    let value: UInt8
}

private struct TokenSerializer: Serializing {
    borrowing func serialize(_ output: borrowing Token, into buffer: inout [UInt8]) {
        buffer.append(output.value)
    }
}
