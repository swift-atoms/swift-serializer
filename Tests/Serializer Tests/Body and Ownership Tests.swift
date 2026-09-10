import Serializer
import Testing

@Suite struct `Serializer bodies preserve exact failures and ownership` {
    @Test func `opaque infallible body needs no try`() {
        var buffer: [Int] = []
        Infallible().serialize(3, into: &buffer)
        #expect(buffer == [3])
        let _: Infallible.Failure.Type = Never.self
    }

    @Test func `opaque fallible body preserves its exact failure`() {
        var buffer: [Int] = []
        #expect(throws: Rejection.negative) { try Positive().serialize(-1, into: &buffer) }
        #expect(buffer.isEmpty)
        let _: Positive.Failure.Type = Rejection.self
    }

    @Test func `direct closure and body borrow scoped values`() {
        let values = [3, 5]
        var buffer: [Int] = []
        let serializer = Serializer<Span<Int>, [Int], Never> { Scoped() }
        serializer.serialize(values.span, into: &buffer)
        ScopedBody().serialize(values.span, into: &buffer)
        #expect(buffer == [3, 5, 3, 5])
        #expect(values == [3, 5])
    }

    @Test func `present optional failures propagate without disappearing`() {
        var buffer: [Int] = []
        let serializer = Optional<Positive>.Serializer(Positive())
        #expect(throws: Rejection.negative) { try serializer.serialize(-1, into: &buffer) }
        #expect(buffer.isEmpty)
    }

    @Test func `body construction retains one noncopyable owner`() {
        let lifetime = Lifetime()
        var buffer: [Int] = []
        let serializer = Serializer<Int, [Int], Never> { Owned(lifetime: lifetime) }
        #expect(lifetime.destroyed == 0)
        serializer.serialize(3, into: &buffer)
        serializer.serialize(5, into: &buffer)
        #expect(buffer == [3, 5])
        #expect(lifetime.destroyed == 0)
    }
}

private enum Rejection: Error, Equatable { case negative }
private struct Infallible: Serializing {
    var body: some Serializing<Int, [Int], Never> {
        Serializer<Int, [Int], Never> { value, buffer in buffer.append(value) }
    }
}
private struct Positive: Serializing {
    var body: some Serializing<Int, [Int], Rejection> {
        Serializer<Int, [Int], Rejection> { value, buffer throws(Rejection) in
            guard value >= 0 else { throw .negative }
            buffer.append(value)
        }
    }
}
private struct Scoped: Serializing {
    borrowing func serialize(_ output: borrowing Span<Int>, into buffer: inout [Int]) {
        for value in output { buffer.append(value) }
    }
}
private struct ScopedBody: Serializing {
    var body: some Serializing<Span<Int>, [Int], Never> { Scoped() }
}
private final class Lifetime { var destroyed = 0 }
private struct Owned: ~Copyable, Serializing {
    let lifetime: Lifetime
    deinit { lifetime.destroyed += 1 }
    borrowing func serialize(_ output: Int, into buffer: inout [Int]) { buffer.append(output) }
}

#if Pair
@Suite struct `Serializer structural builder borrows product fields` {
    @Test func `noncopyable fields survive repeated serialization`() {
        let value = Pair(Field(value: 2), Field(value: 7))
        let serializer = Serializer { FieldSerializer(); FieldSerializer() }
        var buffer: [Int] = []
        serializer.serialize(value, into: &buffer)
        serializer.serialize(value, into: &buffer)
        #expect(buffer == [2, 7, 2, 7])
        #expect(value.first.value == 2 && value.second.value == 7)
    }
    @Test func `noncopyable serializer components remain owned`() {
        let first = Lifetime()
        let second = Lifetime()
        let serializer = Serializer { Owned(lifetime: first); Owned(lifetime: second) }
        var buffer: [Int] = []
        serializer.serialize(Pair(2, 7), into: &buffer)
        #expect(buffer == [2, 7])
        #expect(first.destroyed == 0 && second.destroyed == 0)
    }
}
private struct Field: ~Copyable { let value: Int }
private struct FieldSerializer: Serializing {
    borrowing func serialize(_ output: borrowing Field, into buffer: inout [Int]) {
        buffer.append(output.value)
    }
}
#endif

#if Either
@Suite struct `Serializer conditional construction chooses one branch` {
    @Test func `condition is decided during construction`() throws {
        var chooseFirst = true
        let serializer = Serializer {
            if chooseFirst { Infallible() } else { Positive() }
        }
        chooseFirst = false
        var buffer: [Int] = []
        try serializer.serialize(-1, into: &buffer)
        #expect(buffer == [-1])
        #expect(!chooseFirst)
    }
    @Test func `selected branch preserves failure provenance`() {
        let selectFirst = false
        let serializer = Serializer {
            if selectFirst { Infallible() } else { Positive() }
        }
        var buffer: [Int] = []
        #expect(throws: Either<Never, Rejection>.right(.negative)) {
            try serializer.serialize(-1, into: &buffer)
        }
        #expect(buffer.isEmpty)
    }
}
#endif
