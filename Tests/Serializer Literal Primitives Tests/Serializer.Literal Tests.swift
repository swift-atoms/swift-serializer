// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-serializer-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-serializer-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Per [TEST-033] (proposed): one test target per source target. This test
// target covers ONLY the `Serializer Literal Primitives` source target —
// ``Serializer/Literal`` (fixed-byte emission, Void output, Never failure)
// and its `ExpressibleByStringLiteral` /
// `ExpressibleByUnicodeScalarLiteral` /
// `ExpressibleByExtendedGraphemeClusterLiteral` conformances.

import Byte_Primitives
import Serializer_Literal_Primitives
import Testing

// MARK: - Test Suite Structure

@Suite struct `Literal Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Literal Tests`.Unit {

    @Test
    func `Literal from byte array appends bytes`() {
        let literal = Serializer.Literal<[Byte]>([0x48, 0x69] as [Byte])  // "Hi"
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

// MARK: - Edge Cases

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

// MARK: - Integration — Conformance through Serializer.Protocol

extension `Literal Tests`.Integration {

    @Test
    func `Literal conforms to Serializer.Protocol with Void Output`() {
        // Type-level verification: passing Literal through a Serializer.Protocol
        // constraint resolves only if conformance is in place.
        func acceptsAnySerializer<S: Serializer.`Protocol`>(_ s: S) -> S.Output.Type {
            return S.Output.self
        }

        let literal = Serializer.Literal<[Byte]>("hi")
        let outputType = acceptsAnySerializer(literal)
        #expect(outputType == Void.self)
    }

    @Test
    func `Literal is Failure == Never`() {
        // Type-level verification: the Failure of Serializer.Literal is Never.
        let _: Serializer.Literal<[Byte]>.Failure.Type = Never.self
    }

    @Test
    func `Literal via Buffer-returning convenience extension`() {
        // The `Buffer: RangeReplaceableCollection, Failure == Never`
        // default extension on `Serializer.Protocol` provides
        // `serialize() -> Buffer`.
        let literal = Serializer.Literal<[Byte]>("xyz")
        let buffer: [Byte] = literal.serialize(())
        #expect(buffer == "xyz".utf8.map(Byte.init))
    }
}
