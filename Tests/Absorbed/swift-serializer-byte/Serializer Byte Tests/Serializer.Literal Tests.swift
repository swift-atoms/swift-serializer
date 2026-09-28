#if Byte
public import Carrier
import struct Byte.Byte
import Serializer
import Testing

private struct Octet: Carrier.`Protocol` {
    typealias Underlying = UInt8

    let underlying: UInt8

    init(_ underlying: UInt8) {
        self.underlying = underlying
    }
}

@Suite struct `Literal Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Literal Tests`.Unit {

    @Test
    func `Literal from byte array appends bytes`() {
        let literal = Serializer::Literal<[Byte]>([Byte(bitPattern: 0x48), Byte(bitPattern: 0x69)] as [Byte])
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == [Byte(bitPattern: 0x48), Byte(bitPattern: 0x69)])
    }

    @Test
    func `Literal accepts any UInt8 carrier sequence`() {
        let literal = Serializer::Literal<[Byte]>([
            Octet(0xCA),
            Octet(0xFE),
        ])
        var buffer: [Byte] = []

        literal.serialize((), into: &buffer)

        #expect(buffer == [Byte(bitPattern: 0xCA), Byte(bitPattern: 0xFE)])
    }

    @Test
    func `Literal supports another range-replaceable byte buffer`() {
        let literal = Serializer::Literal<ContiguousArray<Byte>>([Byte(bitPattern: 0x01), Byte(bitPattern: 0x02)] as [Byte])
        var buffer: ContiguousArray<Byte> = [Byte(bitPattern: 0x00)]

        literal.serialize((), into: &buffer)

        #expect(buffer == [Byte(bitPattern: 0x00), Byte(bitPattern: 0x01), Byte(bitPattern: 0x02)])
    }

    @Test
    func `Literal from StaticString appends UTF-8 bytes`() {
        let literal = Serializer::Literal<[Byte]>("Hi")
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == "Hi".utf8.map(Byte.init(bitPattern:)))
    }

    @Test
    func `Literal appends to existing buffer (does not replace)`() {
        let literal = Serializer::Literal<[Byte]>(", world")
        var buffer: [Byte] = "hello".utf8.map(Byte.init(bitPattern:))
        literal.serialize((), into: &buffer)
        #expect(buffer == "hello, world".utf8.map(Byte.init(bitPattern:)))
    }
}

extension `Literal Tests`.`Edge Case` {

    @Test
    func `Literal with empty bytes is a no-op`() {
        let literal = Serializer::Literal<[Byte]>([] as [Byte])
        var buffer: [Byte] = "preserved".utf8.map(Byte.init(bitPattern:))
        literal.serialize((), into: &buffer)
        #expect(buffer == "preserved".utf8.map(Byte.init(bitPattern:)))
    }

    @Test
    func `Literal from string literal compiles via ExpressibleByStringLiteral`() {
        let literal: Serializer::Literal<[Byte]> = ", "
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == ", ".utf8.map(Byte.init(bitPattern:)))
    }
}

extension `Literal Tests`.Integration {

    @Test
    func `Literal conforms to Serializer.Protocol with Void Output`() {

        func acceptsAnySerializer<S: Serializing>(_ s: S) -> S.Output.Type {
            return S.Output.self
        }

        let literal = Serializer::Literal<[Byte]>("hi")
        let outputType = acceptsAnySerializer(literal)
        #expect(outputType == Void.self)
    }

    @Test
    func `Literal is Failure == Never`() {

        let _: Serializer::Literal<[Byte]>.Failure.Type = Never.self
    }

    @Test
    func `Literal via Buffer-returning convenience extension`() {

        let literal = Serializer::Literal<[Byte]>("xyz")
        let buffer: [Byte] = literal.serialize(())
        #expect(buffer == "xyz".utf8.map(Byte.init(bitPattern:)))
    }
}
#endif
