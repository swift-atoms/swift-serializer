import Byte
import Byte_Protocol
import Serializer_Literal
import Testing

@Suite struct `Literal Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Literal Tests`.Unit {

    @Test
    func `Literal from byte array appends bytes`() {
        let literal = Serializer.Literal<[Byte]>([0x48, 0x69] as [Byte])
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == [0x48, 0x69])
    }

    @Test
    func `Literal from StaticString appends UTF-8 bytes`() {
        let literal = Serializer.Literal<[Byte]>("Hi")
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == "Hi".utf8.map(Byte.init))
    }

    @Test
    func `Literal appends to existing buffer (does not replace)`() {
        let literal = Serializer.Literal<[Byte]>(", world")
        var buffer: [Byte] = "hello".utf8.map(Byte.init)
        literal.serialize((), into: &buffer)
        #expect(buffer == "hello, world".utf8.map(Byte.init))
    }
}

extension `Literal Tests`.`Edge Case` {

    @Test
    func `Literal with empty bytes is a no-op`() {
        let literal = Serializer.Literal<[Byte]>([] as [Byte])
        var buffer: [Byte] = "preserved".utf8.map(Byte.init)
        literal.serialize((), into: &buffer)
        #expect(buffer == "preserved".utf8.map(Byte.init))
    }

    @Test
    func `Literal from string literal compiles via ExpressibleByStringLiteral`() {
        let literal: Serializer.Literal<[Byte]> = ", "
        var buffer: [Byte] = []
        literal.serialize((), into: &buffer)
        #expect(buffer == ", ".utf8.map(Byte.init))
    }
}

extension `Literal Tests`.Integration {

    @Test
    func `Literal conforms to Serializer.Protocol with Void Output`() {

        func acceptsAnySerializer<S: Serializer.`Protocol`>(_ s: S) -> S.Output.Type {
            return S.Output.self
        }

        let literal = Serializer.Literal<[Byte]>("hi")
        let outputType = acceptsAnySerializer(literal)
        #expect(outputType == Void.self)
    }

    @Test
    func `Literal is Failure == Never`() {

        let _: Serializer.Literal<[Byte]>.Failure.Type = Never.self
    }

    @Test
    func `Literal via Buffer-returning convenience extension`() {

        let literal = Serializer.Literal<[Byte]>("xyz")
        let buffer: [Byte] = literal.serialize(())
        #expect(buffer == "xyz".utf8.map(Byte.init))
    }
}
