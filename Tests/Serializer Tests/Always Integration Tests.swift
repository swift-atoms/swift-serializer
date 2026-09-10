#if Always
import Always
import Serializer
import Testing

@Suite
struct `Always.Serializer` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Always.Serializer`.Unit {
    @Test
    func `writes nothing to the buffer`() {
        let serializer = Always<Int>.Serializer<[UInt8]>(42)
        var buffer: [UInt8] = [0x01, 0x02]

        serializer.serialize(7, into: &buffer)

        #expect(buffer == [0x01, 0x02])
    }

    @Test
    func `accepts Void output`() {
        let serializer = Always<Void>.Serializer<[UInt8]>(())
        var buffer: [UInt8] = [0xFF]

        serializer.serialize((), into: &buffer)

        #expect(buffer == [0xFF])
    }

    @Test
    func `lifts an Always through serializer()`() {
        let serializer: Always<Int>.Serializer<[UInt8]> = Always(7).serializer()
        var buffer: [UInt8] = []

        serializer.serialize(1, into: &buffer)

        #expect(buffer.isEmpty)
        #expect(serializer.base.value == 7)
    }
}

extension `Always.Serializer`.`Edge Case` {
    @Test
    func `leaves an empty buffer empty`() {
        let serializer = Always<String>.Serializer<[UInt8]>("hello")
        var buffer: [UInt8] = []

        serializer.serialize("world", into: &buffer)

        #expect(buffer.isEmpty)
    }
}

#endif
