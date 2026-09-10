#if Either
import Either
import Serializer
import Testing

@Suite
struct `Either Serializer` {

    @Test
    func `serializes through the selected left serializer`() throws(any Swift.Error) {
        var buffer: [UInt8] = []

        try branch(true).serializer().serialize("a", into: &buffer)

        #expect(buffer == Array("a".utf8))
    }

    @Test
    func `serializes through the selected right serializer`() throws(any Swift.Error) {
        var buffer: [UInt8] = []

        try branch(false).serializer().serialize("b", into: &buffer)

        #expect(buffer == Array("b".utf8))
    }

    @Test
    func `attributes the left failure to Either left`() {
        var buffer: [UInt8] = []

        #expect(throws: Either<LiteralError, LiteralError>.left(.expected("a"))) {
            try branch(true).serializer().serialize("z", into: &buffer)
        }
    }

    @Test
    func `attributes the right failure to Either right`() {
        var buffer: [UInt8] = []

        #expect(throws: Either<LiteralError, LiteralError>.right(.expected("b"))) {
            try branch(false).serializer().serialize("z", into: &buffer)
        }
    }
}

private func branch(_ useLeft: Bool) -> Either<Literal, Literal> {
    useLeft ? .left(Literal("a")) : .right(Literal("b"))
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
