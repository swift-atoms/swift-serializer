import Serializer_Standard_Library_Integration
import Serializer_Witness
import Testing

@Suite
struct `Serializer Standard Library Integration Tests` {
    @Suite struct `Serializer Optional` {}
    @Suite struct Optionally {}
    @Suite struct Serializable {}
}

extension `Serializer Standard Library Integration Tests`.`Serializer Optional` {

    @Test
    func `a present serializer emits its output`() {
        let serializer = Serializer.Optional(Digit())
        var buffer: [UInt8] = []

        serializer.serialize(7, into: &buffer)

        #expect(buffer == [7])
    }

    @Test
    func `an absent serializer emits nothing`() {
        let serializer = Serializer.Optional<Digit>(nil)
        var buffer: [UInt8] = []

        serializer.serialize(7, into: &buffer)

        #expect(buffer.isEmpty)
    }

    @Test
    func `a present serializer with a nil output emits nothing`() {
        let serializer = Serializer.Optional(Digit())
        var buffer: [UInt8] = []

        serializer.serialize(nil, into: &buffer)

        #expect(buffer.isEmpty)
    }

    @Test
    func `the builder lifts an optional serializer through buildIf`() {
        var buffer: [UInt8] = []

        conditional(true).serialize(7, into: &buffer)
        #expect(buffer == [7])

        var empty: [UInt8] = []
        conditional(false).serialize(7, into: &empty)
        #expect(empty.isEmpty)
    }
}

extension `Serializer Standard Library Integration Tests`.Optionally {

    @Test
    func `emits the wrapped output when present`() {
        let serializer = Serializer.Optionally(Digit())
        var buffer: [UInt8] = []

        serializer.serialize(9, into: &buffer)

        #expect(buffer == [9])
    }

    @Test
    func `emits nothing when the output is nil`() {
        let serializer = Serializer.Optionally(Digit())
        var buffer: [UInt8] = []

        serializer.serialize(nil, into: &buffer)

        #expect(buffer.isEmpty)
    }
}

extension `Serializer Standard Library Integration Tests`.Serializable {

    @Test
    func `Swift Optional is serializable when its wrapped value is`() {
        var buffer: [UInt8] = []

        Swift.Optional<Count>.serializer.serialize(Count(value: 3), into: &buffer)
        #expect(buffer == [3])

        Swift.Optional<Count>.serializer.serialize(nil, into: &buffer)
        #expect(buffer == [3])
    }
}

@Serializer.Builder<[UInt8]>
private func conditional(_ include: Bool) -> Serializer.Optional<Digit> {
    if include {
        Digit()
    }
}

private struct Digit: Serializer.`Protocol` {
    typealias Output = UInt8
    typealias Buffer = [UInt8]
    typealias Failure = Never
    typealias Body = Never

    borrowing func serialize(_ output: UInt8, into buffer: inout [UInt8]) {
        buffer.append(output)
    }
}

private struct Count: Serializable {
    let value: UInt8

    static var serializer: Serializer::Serializer.Witness<Count, [UInt8], Never> {
        Serializer::Serializer.Witness { count, buffer in
            buffer.append(count.value)
        }
    }
}
