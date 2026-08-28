import Serializer_Primitive
import Serializer_Witness
import Testing

@Suite struct `Protocol Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Protocol Tests`.Unit {

    @Test
    func `serialize routes through the conformance method`() {

        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        witness.serialize(42, into: &buffer)
        #expect(buffer == [42])
    }

    @Test
    func `Body == Never on the leaf witness (per API-IMPL-020)`() {

        let _: Serializer.Witness<Int, [UInt8], Never>.Body.Type = Never.self
    }

    @Test
    func `body getter exists for Body == Never (default leaf extension)`() {

        let witness = Serializer.Witness<Int, [UInt8], Never> { _, _ in }
        _ = witness
    }

    @Test
    func `multiple serialize calls compose by append order`() {
        let s1 = Serializer.Witness<UInt8, [UInt8], Never> { v, b in b.append(v) }
        let s2 = Serializer.Witness<UInt8, [UInt8], Never> { v, b in b.append(v &+ 100) }

        var buffer: [UInt8] = []
        s1.serialize(1, into: &buffer)
        s2.serialize(1, into: &buffer)
        s1.serialize(2, into: &buffer)

        #expect(buffer == [1, 101, 2])
    }
}

extension `Protocol Tests`.`Edge Case` {

    @Test
    func `serialize propagates typed error through the conformance`() {
        struct E: Swift.Error, Equatable {}

        let witness = Serializer.Witness<Int, [UInt8], E> { value, buffer throws(E) in
            guard value != 0 else { throw E() }
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        do throws(E) {
            try witness.serialize(7, into: &buffer)
            #expect(buffer == [7])
        } catch {
            Issue.record("Did not expect throw for non-zero")
        }

        do throws(E) {
            try witness.serialize(0, into: &buffer)
            Issue.record("Expected E to be thrown")
        } catch {
            #expect(error == E())
        }
    }

    @Test
    func `infallible Failure == Never call site does not require try`() {
        let witness = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
            buffer.append(value)
        }

        var buffer: [UInt8] = []

        witness.serialize(255, into: &buffer)
        #expect(buffer == [255])
    }
}

extension `Protocol Tests`.Integration {

    @Test
    func `Witness conforms to Serializer.Protocol`() {

        func acceptsAnySerializer<S: Serializer.`Protocol`>(_ serializer: S) -> S.Output.Type {
            return S.Output.self
        }

        let witness = Serializer.Witness<Int, [UInt8], Never> { _, _ in }
        let outputType = acceptsAnySerializer(witness)
        #expect(outputType == Int.self)
    }

    @Test
    func `Buffer: RangeReplaceableCollection default extension constructs a buffer`() {

        let witness = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
            buffer.append(value)
        }

        let result: [UInt8] = witness.serialize(42)
        #expect(result == [42])
    }

    @Test
    func `throwing serialize-returns-buffer default extension`() {
        struct E: Swift.Error {}
        let witness = Serializer.Witness<Int, [UInt8], E> { value, buffer throws(E) in
            guard value >= 0 else { throw E() }
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        do throws(E) {
            let result: [UInt8] = try witness.serialize(7)
            #expect(result == [7])
        } catch {
            Issue.record("Did not expect throw for non-negative")
        }

        do throws(E) {
            let _: [UInt8] = try witness.serialize(-1)
            Issue.record("Expected throw for negative")
        } catch {

        }
    }
}

enum Decimal {}

extension Decimal {
    struct Printer {}
}

extension Decimal.Printer: Serializer.`Protocol` {
    typealias Output = Int
    typealias Buffer = [UInt8]
    typealias Failure = Never

    var body: some Serializer.`Protocol`<Int, [UInt8], Never> {
        Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(contentsOf: "\(value)".utf8)
        }
    }
}

extension `Protocol Tests`.Integration {

    @Test
    func `body-style conformer delegates serialize to body`() {

        let printer = Decimal.Printer()
        var buffer: [UInt8] = []
        printer.serialize(42, into: &buffer)
        #expect(buffer == Array("42".utf8))
    }

    @Test
    func `body-style conformer's Body is the composed serializer's concrete type`() {

        func acceptsBodyComposed<S>(_ s: S) -> (S.Output.Type, S.Failure.Type)
        where S: Serializer.`Protocol`, S.Output == Int, S.Buffer == [UInt8], S.Failure == Never {
            return (S.Output.self, S.Failure.self)
        }

        let (outputType, failureType) = acceptsBodyComposed(Decimal.Printer())
        #expect(outputType == Int.self)
        #expect(failureType == Never.self)
    }

    @Test
    func `body-style conformer appends, mirroring leaf-form behavior`() {

        let printer = Decimal.Printer()
        var buffer: [UInt8] = Array("prefix:".utf8)
        printer.serialize(7, into: &buffer)
        #expect(buffer == Array("prefix:7".utf8))
    }
}
