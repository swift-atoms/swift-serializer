import Serializer
import Serializer_Witness
import Testing

@Suite
struct `Serializer.Witness` {

    @Test
    func `a witness serializes through its closure`() {
        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }
        var buffer: [UInt8] = [10]
        witness.serialize(40, into: &buffer)
        #expect(buffer == [10, 40])
    }

    @Test
    func `a pure witness needs no try`() {
        let pure = Serializer.Pure<UInt8, [UInt8]> { value, buffer in buffer.append(value) }
        var buffer: [UInt8] = []
        pure.serialize(255, into: &buffer)
        #expect(buffer == [255])
    }

    @Test
    func `a witness propagates its typed failure`() {
        struct Forbidden: Swift.Error, Equatable {}
        let witness = Serializer.Witness<Int, [UInt8], Forbidden> { value, buffer throws(Forbidden) in
            guard value != 0 else { throw Forbidden() }
            buffer.append(UInt8(truncatingIfNeeded: value))
        }
        var buffer: [UInt8] = []
        #expect(throws: Forbidden()) {
            try witness.serialize(0, into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `a witness borrows a noncopyable output`() {
        struct Token: ~Copyable {
            let value: UInt8
        }
        let witness = Serializer.Witness<Token, [UInt8], Never> { token, buffer in
            buffer.append(token.value)
        }
        var buffer: [UInt8] = []
        let token = Token(value: 3)
        witness.serialize(token, into: &buffer)
        #expect(buffer == [3])
        #expect(token.value == 3)
    }
}
