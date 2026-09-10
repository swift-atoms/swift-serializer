#if Repetition
import Either
import Serializer
import Testing

@Suite
struct `Collection Serializer Many Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Collection Serializer Many Tests`.Unit {

    @Test
    func `emits every element in order`() throws(any Swift.Error) {
        let serializer = Repetition(Cardinal.zero..., operation: RepeatedCharacter()).serializer()

        var buffer: [UInt8] = []
        try serializer.serialize(["a", "b", "c"], into: &buffer)

        #expect(buffer == Array("abc".utf8))
    }

    @Test
    func `emits a separator between elements`() throws(any Swift.Error) {
        let serializer = Repetition(Cardinal.zero..., operation: RepeatedCharacter()).serializer(separator: RepeatedComma())

        var buffer: [UInt8] = []
        try serializer.serialize(["a", "b", "c"], into: &buffer)

        #expect(buffer == Array("a,b,c".utf8))
    }
}

extension `Collection Serializer Many Tests`.`Edge Case` {

    @Test
    func `rejects fewer elements than the minimum`() {
        let serializer = Repetition(Cardinal(2)...Cardinal(3), operation: RepeatedCharacter()).serializer()

        var buffer: [UInt8] = []
        #expect(throws: Either<Repetition<ClosedRange<Cardinal>, RepeatedCharacter>.Error, Never>.self) {
            try serializer.serialize(["a"], into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `rejects more elements than the maximum`() {
        let serializer = Repetition(Cardinal(1)...Cardinal(2), operation: RepeatedCharacter()).serializer()

        var buffer: [UInt8] = []
        #expect(throws: Either<Repetition<ClosedRange<Cardinal>, RepeatedCharacter>.Error, Never>.self) {
            try serializer.serialize(["a", "b", "c"], into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `emits nothing for an empty output`() throws(any Swift.Error) {
        let serializer = Repetition(Cardinal.zero..., operation: RepeatedCharacter()).serializer()

        var buffer: [UInt8] = []
        try serializer.serialize([], into: &buffer)

        #expect(buffer.isEmpty)
    }
}

struct RepeatedCharacter: Serializing {
    typealias Output = Character
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: Character, into buffer: inout [UInt8]) {
        buffer.append(contentsOf: String(output).utf8)
    }
}

struct RepeatedComma: Serializing {
    typealias Output = Void
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: Void, into buffer: inout [UInt8]) {
        buffer.append(UInt8(ascii: ","))
    }
}

#endif
