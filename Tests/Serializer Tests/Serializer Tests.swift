import Serializer
import Testing

@Suite struct `Witness Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Witness Tests`.Unit {

    @Test
    func `init stores the serialize closure`() {

        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        witness._serialize(42, &buffer)
        #expect(buffer == [42])
    }

    @Test
    func `_serialize closure is callable multiple times`() {
        var calls = 0
        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            calls += 1
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        witness._serialize(1, &buffer)
        witness._serialize(2, &buffer)
        witness._serialize(3, &buffer)

        #expect(calls == 3)
        #expect(buffer == [1, 2, 3])
    }

    @Test
    func `_serialize appends to existing buffer, not replaces it`() {
        let witness = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
            buffer.append(value)
        }

        var buffer: [UInt8] = [10, 20, 30]
        witness._serialize(40, &buffer)
        #expect(buffer == [10, 20, 30, 40])
    }
}

extension `Witness Tests`.`Edge Case` {

    @Test
    func `_serialize into empty buffer`() {
        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        witness._serialize(99, &buffer)
        #expect(buffer == [99])
    }

    @Test
    func `_serialize closure with typed throws propagates the error`() {
        struct Forbidden: Swift.Error, Equatable {}

        let witness = Serializer.Witness<Int, [UInt8], Forbidden> {
            value,
            buffer throws(Forbidden) in
            guard value != 0 else { throw Forbidden() }
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        do throws(Forbidden) {
            try witness._serialize(7, &buffer)
            #expect(buffer == [7])
        } catch {
            Issue.record("Did not expect throw for non-zero")
        }

        do throws(Forbidden) {
            try witness._serialize(0, &buffer)
            Issue.record("Expected Forbidden to be thrown")
        } catch {
            #expect(error == Forbidden())
        }
    }
}
