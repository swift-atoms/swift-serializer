import Testing
@testable import Serialization_Primitives

@Suite struct SerializationTests {

    // MARK: - Serializing.Value

    @Suite("Serializing.Value")
    struct SerializingValueTests {
        @Test func serializesValueToRepresentation() throws {
            let serializer: Serialization.Serializing.Value<Int, String, Void, Never> = .init { value, _ in
                "\(value)"
            }
            let result = serializer.call(42)
            #expect(result == "42")
        }

        @Test func serializesWithContext() throws {
            let serializer: Serialization.Serializing.Value<Int, String, String, Never> = .init { value, prefix in
                "\(prefix)\(value)"
            }
            let result = serializer.call(42, ("PREFIX: "))
            #expect(result == "PREFIX: 42")
        }

        @Test func throwsOnFailure() {
            enum TestError: Error, Sendable { case failed }
            let serializer: Serialization.Serializing.Value<Int, String, Void, TestError> = .init { (value: Int, _: Void) throws(TestError) -> String in
                guard value > 0 else { throw TestError.failed }
                return "\(value)"
            }
            #expect(throws: TestError.self) {
                try serializer.call(-1)
            }
        }
    }

    // MARK: - Serializing.Buffer

    @Suite("Serializing.Buffer")
    struct SerializingBufferTests {
        @Test func appendsToBuffer() throws {
            let serializer: Serialization.Serializing.Buffer<UInt16, UInt8, Void> = .init { value, _, buffer in
                buffer.append(UInt8(truncatingIfNeeded: value >> 8))
                buffer.append(UInt8(truncatingIfNeeded: value))
            }
            var buffer: [UInt8] = []
            serializer.call(0xABCD, into: &buffer)
            #expect(buffer == [0xAB, 0xCD])
        }

        @Test func returningCreatesNewArray() throws {
            let serializer: Serialization.Serializing.Buffer<UInt16, UInt8, Void> = .init { value, _, buffer in
                buffer.append(UInt8(truncatingIfNeeded: value >> 8))
                buffer.append(UInt8(truncatingIfNeeded: value))
            }
            let bytes = serializer.returning(0xABCD)
            #expect(bytes == [0xAB, 0xCD])
        }

        @Test func appendsMultipleValues() throws {
            let serializer: Serialization.Serializing.Buffer<UInt8, UInt8, Void> = .init { value, _, buffer in
                buffer.append(value)
            }
            var buffer: [UInt8] = []
            serializer.call(0x01, into: &buffer)
            serializer.call(0x02, into: &buffer)
            serializer.call(0x03, into: &buffer)
            #expect(buffer == [0x01, 0x02, 0x03])
        }
    }

    // MARK: - Parsing.Whole

    @Suite("Parsing.Whole")
    struct ParsingWholeTests {
        @Test func parsesCompleteRepresentation() throws {
            let parser: Serialization.Parsing.Whole<Int, String, Void, Never> = .init { string, _ in
                Int(string) ?? 0
            }
            let result = parser.call("42")
            #expect(result == 42)
        }

        @Test func parsesWithContext() throws {
            let parser: Serialization.Parsing.Whole<Int, String, Int, Never> = .init { string, radix in
                Int(string, radix: radix) ?? 0
            }
            let result = parser.call("FF", (16))
            #expect(result == 255)
        }

        @Test func throwsOnFailure() {
            enum ParseError: Error, Sendable { case invalid }
            let parser: Serialization.Parsing.Whole<Int, String, Void, ParseError> = .init { (string: String, _: Void) throws(ParseError) -> Int in
                guard let value = Int(string) else { throw ParseError.invalid }
                return value
            }
            #expect(throws: ParseError.self) {
                try parser.call("not a number")
            }
        }
    }

    // MARK: - Parsing.Prefix.Witness

    @Suite("Parsing.Prefix.Witness")
    struct ParsingPrefixWitnessTests {
        @Test func parsesPrefixAndReturnsCount() throws {
            let parser: Serialization.Parsing.Prefix.Witness<Int, Int, [UInt8], Void, Never> = .init { bytes, _ in
                var value = 0
                var count = 0
                for byte in bytes where byte >= 0x30 && byte <= 0x39 {
                    value = value * 10 + Int(byte - 0x30)
                    count += 1
                }
                return .init(value: value, count: count)
            }
            let result = parser.call([0x31, 0x32, 0x33, 0x41, 0x42]) // "123AB"
            #expect(result.value == 123)
            #expect(result.count == 3)
        }

        @Test func countEnablesRemainderComputation() throws {
            let parser: Serialization.Parsing.Prefix.Witness<Int, Int, [UInt8], Void, Never> = .init { bytes, _ in
                var value = 0
                var count = 0
                for byte in bytes where byte >= 0x30 && byte <= 0x39 {
                    value = value * 10 + Int(byte - 0x30)
                    count += 1
                }
                return .init(value: value, count: count)
            }
            let bytes: [UInt8] = [0x31, 0x32, 0x33, 0x41, 0x42]
            let result = parser.call(bytes)
            let remainder = Array(bytes.dropFirst(result.count))
            #expect(remainder == [0x41, 0x42])
        }
    }

    // MARK: - Parsing.Prefix.Result

    @Suite("Parsing.Prefix.Result")
    struct ParsingPrefixResultTests {
        @Test func storesValueAndCount() {
            let result: Serialization.Parsing.Prefix.Result<String, Int> = .init(value: "hello", count: 5)
            #expect(result.value == "hello")
            #expect(result.count == 5)
        }

        @Test func isSendable() {
            let result: Serialization.Parsing.Prefix.Result<Int, Int> = .init(value: 42, count: 2)
            // Verify Sendable by passing to concurrent context
            Task {
                _ = result.value
                _ = result.count
            }
        }
    }

    // MARK: - Measuring

    @Suite("Measuring")
    struct MeasuringTests {
        @Test func measuresSerializedSize() throws {
            let measuring: Serialization.Measuring<String, Void> = .init { string, _ in
                string.utf8.count
            }
            let size = measuring.call("Hello")
            #expect(size == 5)
        }

        @Test func measuresWithContext() throws {
            let measuring: Serialization.Measuring<[Int], Int> = .init { array, elementSize in
                array.count * elementSize
            }
            let size = measuring.call([1, 2, 3], (4))  // 3 elements × 4 bytes
            #expect(size == 12)
        }

        @Test func enablesReserveCapacity() throws {
            let measuring: Serialization.Measuring<UInt32, Void> = .init { _, _ in 4 }
            let serializer: Serialization.Serializing.Buffer<UInt32, UInt8, Void> = .init { value, _, buffer in
                buffer.append(UInt8(truncatingIfNeeded: value >> 24))
                buffer.append(UInt8(truncatingIfNeeded: value >> 16))
                buffer.append(UInt8(truncatingIfNeeded: value >> 8))
                buffer.append(UInt8(truncatingIfNeeded: value))
            }

            var buffer: [UInt8] = []
            buffer.reserveCapacity(measuring.call(0xDEADBEEF))
            serializer.call(0xDEADBEEF, into: &buffer)
            #expect(buffer == [0xDE, 0xAD, 0xBE, 0xEF])
        }
    }

    // MARK: - Round-trip

    @Suite("Round-trip")
    struct RoundTripTests {
        @Test func serializeParseRoundTrip() throws {
            let serializer: Serialization.Serializing.Buffer<UInt32, UInt8, Void> = .init { value, _, buffer in
                buffer.append(UInt8(truncatingIfNeeded: value >> 24))
                buffer.append(UInt8(truncatingIfNeeded: value >> 16))
                buffer.append(UInt8(truncatingIfNeeded: value >> 8))
                buffer.append(UInt8(truncatingIfNeeded: value))
            }

            let parser: Serialization.Parsing.Whole<UInt32, [UInt8], Void, Never> = .init { bytes, _ in
                guard bytes.count >= 4 else { return 0 }
                return UInt32(bytes[0]) << 24
                     | UInt32(bytes[1]) << 16
                     | UInt32(bytes[2]) << 8
                     | UInt32(bytes[3])
            }

            let original: UInt32 = 0xDEADBEEF
            let serialized = serializer.returning(original)
            let parsed = parser.call(serialized)
            #expect(parsed == original)
        }
    }
}
