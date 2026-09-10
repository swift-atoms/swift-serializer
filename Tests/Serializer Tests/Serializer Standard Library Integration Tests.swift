import Serializer
import Testing

@Suite
struct `Optional and array values serialize their present elements` {

    @Test
    func `an optional representation emits the wrapped output when present`() {
        var buffer: [UInt8] = []
        Swift.Optional<CountSerializer>.Serializer(CountSerializer()).serialize(Count(value: 9), into: &buffer)
        #expect(buffer == [9])
    }

    @Test
    func `an optional representation emits nothing when the output is nil`() {
        var buffer: [UInt8] = []
        Swift.Optional<CountSerializer>.Serializer(CountSerializer()).serialize(nil, into: &buffer)
        #expect(buffer.isEmpty)
    }

    @Test
    func `an array serializes itself into a buffer of its elements`() {
        var text = ""
        [Character].Serializer<String>(Array("<tag")).serialize((), into: &text)
        #expect(text == "<tag")

        var bytes: [UInt8] = []
        [UInt8].Serializer<[UInt8]>([1, 2, 3]).serialize((), into: &bytes)
        #expect(bytes == [1, 2, 3])
    }

    @Test
    func `an explicit optional serializer can be reused`() {
        var buffer: [UInt8] = []
        Swift.Optional<CountSerializer>.Serializer(CountSerializer()).serialize(Count(value: 3), into: &buffer)
        #expect(buffer == [3])
        Swift.Optional<CountSerializer>.Serializer(CountSerializer()).serialize(nil, into: &buffer)
        #expect(buffer == [3])
    }
}

private struct Count {
    let value: UInt8

}

private struct CountSerializer: Serializing {
    borrowing func serialize(_ output: Count, into buffer: inout [UInt8]) {
        buffer.append(output.value)
    }
}

@Suite struct `Explicit optional serializers retain owned components` {
    @Test func `noncopyable values and serializers can be borrowed repeatedly`() {
        let serializer = Optional<OwnedCountSerializer>.Serializer(OwnedCountSerializer())
        let value: OwnedCount? = .some(OwnedCount(value: 7))
        var buffer = OwnedBuffer()
        serializer.serialize(value, into: &buffer)
        serializer.serialize(value, into: &buffer)
        serializer.serialize(nil, into: &buffer)
        #expect(buffer.values == [7, 7])
    }
}
private struct OwnedCount: ~Copyable { let value: Int }
private struct OwnedBuffer: ~Copyable { var values: [Int] = [] }
private struct OwnedCountSerializer: Serializing, ~Copyable {
    borrowing func serialize(_ output: borrowing OwnedCount, into buffer: inout OwnedBuffer) {
        buffer.values.append(output.value)
    }
}
