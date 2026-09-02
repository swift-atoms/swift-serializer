import Serializer
import Serializer_Standard_Library_Integration
import Testing

@Suite
struct `Serializer Standard Library Integration` {

    @Test
    func `Optionally emits the wrapped output when present`() {
        let serializer = Serializer.Optionally(Digit())
        var buffer: [UInt8] = []
        serializer.serialize(9, into: &buffer)
        #expect(buffer == [9])
    }

    @Test
    func `Optionally emits nothing when the output is nil`() {
        let serializer = Serializer.Optionally(Digit())
        var buffer: [UInt8] = []
        serializer.serialize(nil, into: &buffer)
        #expect(buffer.isEmpty)
    }

    @Test
    func `Swift Optional is serializable when its wrapped value is`() {
        var buffer: [UInt8] = []
        Swift.Optional<Count>.serializer.serialize(Count(value: 3), into: &buffer)
        #expect(buffer == [3])
        Swift.Optional<Count>.serializer.serialize(nil, into: &buffer)
        #expect(buffer == [3])
    }
}

private struct Digit: Serializer.`Protocol` {
    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) {
        buffer.append(output)
    }
}

private struct Count: Serializable {
    let value: UInt8

    static var serializer: CountSerializer { CountSerializer() }
}

private struct CountSerializer: Serializer.`Protocol` {
    borrowing func serialize(_ output: Count, into buffer: inout [UInt8]) {
        buffer.append(output.value)
    }
}
