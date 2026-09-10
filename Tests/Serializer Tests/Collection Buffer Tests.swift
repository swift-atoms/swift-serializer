#if Collection
import Serializer
import Testing

@Suite
struct `Collection Serializer Buffer Tests` {

    @Test
    func `builds a fresh buffer for a nonfailing serializer`() {
        let serializer = Character.Serializer()

        let buffer: [UInt8] = serializer.serialize("a")

        #expect(buffer == Array("a".utf8))
    }

    @Test
    func `builds a fresh buffer for a failing serializer`() throws(any Swift.Error) {
        let serializer = Literal("a")

        let buffer: [UInt8] = try serializer.serialize("a")

        #expect(buffer == Array("a".utf8))
    }

    @Test
    func `propagates the failure instead of returning a buffer`() {
        let serializer = Literal("a")

        #expect(throws: LiteralError.expected("a")) {
            let _: [UInt8] = try serializer.serialize("b")
        }
    }
}

extension Character {

    fileprivate struct Serializer: Serializing {
        typealias Output = Character
        typealias Buffer = [UInt8]
        typealias Failure = Never

        borrowing func serialize(_ output: Character, into buffer: inout [UInt8]) {
            buffer.append(contentsOf: String(output).utf8)
        }
    }
}

private enum LiteralError: Error, Equatable {
    case expected(Character)
}

private struct Literal: Serializing {
    typealias Output = Character
    typealias Buffer = [UInt8]
    typealias Failure = LiteralError

    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func serialize(
        _ output: Character,
        into buffer: inout [UInt8]
    ) throws(LiteralError) {
        guard output == expected else { throw .expected(expected) }
        buffer.append(contentsOf: String(output).utf8)
    }
}

#endif
