#if Tagged
import Serializer
import Tagged
import Testing

@Suite struct `Tagged Serializer Tests` {

    @Test
    func `Tagged accepts an explicit underlying representation`() {
        let _: Identifier.Serializer<ValueSerializer> = Identifier.Serializer(ValueSerializer())
    }

    @Test
    func `lifted serializer delegates the underlying value`() throws(any Swift.Error) {
        let identifier = Identifier(_unchecked: Value(rawValue: 42))
        var buffer: [Int] = []

        try Identifier.Serializer(ValueSerializer()).serialize(identifier, into: &buffer)

        #expect(buffer == [42])
    }

    @Test
    func `lifted serializer appends into an existing buffer`() throws(any Swift.Error) {
        let identifier = Identifier(_unchecked: Value(rawValue: 42))
        var buffer = [1, 2]

        try Identifier.Serializer(ValueSerializer()).serialize(identifier, into: &buffer)

        #expect(buffer == [1, 2, 42])
    }

    @Test
    func `lifted serializer preserves the underlying failure`() {
        let identifier = Identifier(_unchecked: Value(rawValue: -1))
        var buffer: [Int] = []

        do throws(TestFailure) {
            try Identifier.Serializer(ValueSerializer()).serialize(identifier, into: &buffer)
            Issue.record("Expected the underlying serializer to reject the value")
        } catch {
            #expect(error == .rejected)
        }
        #expect(buffer.isEmpty)
    }
}

private enum IdentifierTag {}

private enum TestFailure: Swift.Error, Equatable {
    case rejected
}

private struct Value {
    let rawValue: Int

}

private struct ValueSerializer: Serializing {
    typealias Output = Value
    typealias Buffer = [Int]
    typealias Failure = TestFailure

    borrowing func serialize(_ output: Value, into buffer: inout [Int]) throws(TestFailure) {
        guard output.rawValue >= 0 else { throw .rejected }
        buffer.append(output.rawValue)
    }
}

private typealias Identifier = Tagged::Tagged<IdentifierTag, Value>

#endif

#if Tagged
@Suite struct `Tagged serialization borrows noncopyable underlying values` {
    @Test func `tagged owned values can be printed repeatedly`() {
        typealias Token = Tagged<IdentifierTag, OwnedValue>
        let token = Token(_unchecked: OwnedValue(rawValue: 9))
        var buffer: [Int] = []
        let serializer = Token.Serializer(OwnedValueSerializer())
        serializer.serialize(token, into: &buffer)
        serializer.serialize(token, into: &buffer)
        #expect(buffer == [9, 9])
        #expect(token.underlying.rawValue == 9)
    }
}
private struct OwnedValue: ~Copyable {
    let rawValue: Int
}
private struct OwnedValueSerializer: ~Copyable, Serializing {
    borrowing func serialize(_ output: borrowing OwnedValue, into buffer: inout [Int]) {
        buffer.append(output.rawValue)
    }
}
#endif
