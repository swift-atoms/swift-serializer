#if Pair
import Either
import Pair
import Serializer
import Testing

@Suite
struct `Pair Serializer Tests` {

    @Test
    func `serializes both halves of a nominal Pair in order`() throws(any Swift.Error) {
        var buffer: [UInt8] = []
        let serializer: Pair::Pair<Literal, OtherLiteral>.Serializer<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).serializer()

        try serializer.serialize(Pair::Pair("a", "b"), into: &buffer)

        #expect(buffer == Array("ab".utf8))
    }

    @Test
    func `attributes first failure to Either left`() {
        var buffer: [UInt8] = []
        let serializer: Pair::Pair<Literal, OtherLiteral>.Serializer<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).serializer()

        #expect(throws: Either<LiteralError, OtherError>.left(.expected("a"))) {
            try serializer.serialize(Pair::Pair("x", "b"), into: &buffer)
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `attributes second failure to Either right`() {
        var buffer: [UInt8] = []
        let serializer: Pair::Pair<Literal, OtherLiteral>.Serializer<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).serializer()

        #expect(throws: Either<LiteralError, OtherError>.right(.expected("b"))) {
            try serializer.serialize(Pair::Pair("a", "x"), into: &buffer)
        }
        #expect(buffer == Array("a".utf8))
    }

    @Test
    func `equally typed failures collapse`() throws(any Swift.Error) {
        var buffer: [UInt8] = []
        let serializer: Pair::Pair<Literal, Literal>.Serializer<LiteralError> =
            Pair::Pair(Literal("a"), Literal("b")).serializer()

        try serializer.serialize(Pair::Pair("a", "b"), into: &buffer)

        #expect(buffer == Array("ab".utf8))
    }

    @Test
    func `Never plus Never collapses to Never and requires no try`() {
        var buffer: [UInt8] = []
        let serializer: Pair::Pair<AnyCharacter, AnyCharacter>.Serializer<Never> =
            Pair::Pair(AnyCharacter(), AnyCharacter()).serializer()

        serializer.serialize(Pair::Pair("a", "b"), into: &buffer)

        #expect(buffer == Array("ab".utf8))
    }
}

private struct AnyCharacter: Serializer::Serializing {
    borrowing func serialize(_ output: Character, into buffer: inout [UInt8]) {
        buffer.append(contentsOf: String(output).utf8)
    }
}

private enum LiteralError: Error, Equatable {
    case expected(Character)
}

private enum OtherError: Error, Equatable {
    case expected(Character)
}

private struct Literal: Serializer::Serializing {
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

private struct OtherLiteral: Serializer::Serializing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func serialize(
        _ output: Character,
        into buffer: inout [UInt8]
    ) throws(OtherError) {
        guard output == expected else { throw .expected(expected) }
        buffer.append(contentsOf: String(output).utf8)
    }
}

#endif
