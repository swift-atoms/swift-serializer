#if Lazy
import Lazy
import Serializer
import Testing

@Suite
struct `Lazy Serializer Tests` {

    @Test
    func `defers serializer construction until serialize time`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy { () -> Literal in
            box.built += 1
            return Literal("a")
        }
        #expect(box.built == 0)

        var buffer: [UInt8] = []
        try lazy.serializer().serialize("a", into: &buffer)

        #expect(buffer == Array("a".utf8))
        #expect(box.built == 1)
    }

    @Test
    func `re-invokes the thunk on every serialize`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy { () -> Literal in
            box.built += 1
            return Literal("a")
        }

        var buffer: [UInt8] = []
        try lazy.serializer().serialize("a", into: &buffer)
        try lazy.serializer().serialize("a", into: &buffer)

        #expect(box.built == 2)
        #expect(buffer == Array("aa".utf8))
    }

    @Test
    func `propagates the wrapped serializer's failure`() {
        let lazy = Lazy(Literal("a"))
        var buffer: [UInt8] = []

        #expect(throws: LiteralError.expected("a")) {
            try lazy.serializer().serialize("b", into: &buffer)
        }
        #expect(buffer.isEmpty)
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

#if Lazy
@Suite struct `Lazy serializer ownership and failure stages` {
    @Test func `throwing factory is retried and creates fresh owned serializers`() throws {
        let state = FactoryState()
        let lazy = Lazy { () throws(FactoryError) -> OwnedSerializer in
            state.built += 1
            guard state.built > 1 else { throw .unavailable }
            return OwnedSerializer(state: state)
        }.serializer()
        var buffer: [Int] = []
        #expect(throws: Either<FactoryError, Never>.left(.unavailable)) {
            try lazy.serialize(2, into: &buffer)
        }
        #expect(buffer.isEmpty && state.destroyed == 0)
        try lazy.serialize(2, into: &buffer)
        #expect(state.destroyed == 1)
        try lazy.serialize(7, into: &buffer)
        #expect(state.destroyed == 2 && state.built == 3)
        #expect(buffer == [2, 7])
    }
    @Test func `infallible factory preserves Never through builder`() {
        let serializer = Serializer { Lazy { IntSerializer() } }
        var buffer: [Int] = []
        serializer.serialize(3, into: &buffer)
        #expect(buffer == [3])
    }
}
private enum FactoryError: Error, Equatable { case unavailable }
private final class FactoryState { var built = 0; var destroyed = 0 }
private struct OwnedSerializer: Serializing, ~Copyable {
    let state: FactoryState
    deinit { state.destroyed += 1 }
    borrowing func serialize(_ output: Int, into buffer: inout [Int]) { buffer.append(output) }
}
private struct IntSerializer: Serializing {
    borrowing func serialize(_ output: Int, into buffer: inout [Int]) { buffer.append(output) }
}
#endif
