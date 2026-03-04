import Testing
import Serializer_ASCII_Integer_Primitives

@Suite("Serializer.ASCII.Integer.Decimal")
struct SerializerASCIIIntegerDecimalTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension SerializerASCIIIntegerDecimalTests.Unit {
    @Test
    func `serializes zero`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt8>()
        let bytes = serializer.serialize(0)
        #expect(bytes == [0x30])
    }

    @Test
    func `serializes single digit`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt8>()
        let bytes = serializer.serialize(7)
        #expect(bytes == [0x37])
    }

    @Test
    func `serializes multi-digit`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt16>()
        let bytes = serializer.serialize(8080)
        #expect(bytes == [0x38, 0x30, 0x38, 0x30])
    }

    @Test
    func `serializes into existing buffer`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt8>()
        var buffer: [UInt8] = [0x41, 0x42] // "AB"
        serializer.serialize(42, into: &buffer)
        #expect(buffer == [0x41, 0x42, 0x34, 0x32])
    }

    @Test
    func `serializes negative`() {
        let serializer = Serializer.ASCII.Integer.Decimal<Int8>()
        let bytes = serializer.serialize(-1)
        #expect(bytes == [0x2D, 0x31]) // "-1"
    }
}

// MARK: - Edge Cases

extension SerializerASCIIIntegerDecimalTests.EdgeCase {
    @Test
    func `serializes UInt8 max`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt8>()
        let bytes = serializer.serialize(.max)
        #expect(bytes == Array("255".utf8))
    }

    @Test
    func `serializes UInt64 max`() {
        let serializer = Serializer.ASCII.Integer.Decimal<UInt64>()
        let bytes = serializer.serialize(.max)
        #expect(bytes == Array("18446744073709551615".utf8))
    }

    @Test
    func `serializes Int64 min`() {
        let serializer = Serializer.ASCII.Integer.Decimal<Int64>()
        let bytes = serializer.serialize(.min)
        #expect(bytes == Array("-9223372036854775808".utf8))
    }

    @Test
    func `serializes Int8 min`() {
        let serializer = Serializer.ASCII.Integer.Decimal<Int8>()
        let bytes = serializer.serialize(.min)
        #expect(bytes == Array("-128".utf8))
    }
}
