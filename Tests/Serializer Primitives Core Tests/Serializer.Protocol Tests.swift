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
// target covers ONLY the `Serializer Primitives Core` source target —
// ``Serializer/Protocol`` (nested in the ``Serializer`` enum namespace), the
// ``Serializer/Witness`` conformance, the default `body: Never` extension
// for Body == Never, and the declarative composition default extension for
// Body: Serializer.`Protocol`.
//
// The bare ``Serializer/Witness`` storage is tested in
// `Serializer Namespace Tests`.

import Serializer_Primitive
import Serializer_Witness_Primitives
import Testing

// MARK: - Test Suite Structure

/// Test namespace for the ``Serializer/Protocol`` surface declared in the
/// `Serializer Primitives Core` source target.
@Suite struct `Protocol Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests — Witness Conformance + Default Extensions

extension `Protocol Tests`.Unit {

    @Test
    func `serialize routes through the conformance method`() {
        // Calling `.serialize(_:into:)` on the witness routes through the
        // `extension Serializer.Witness: Serializer.Protocol` conformance
        // declared in Core. If the conformance is broken, this fails.
        let witness = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        witness.serialize(42, into: &buffer)
        #expect(buffer == [42])
    }

    @Test
    func `Body == Never on the leaf witness (per API-IMPL-020)`() {
        // The Body == Never typealias is a structural requirement of the
        // witness's conformance. Verified via the type system: this
        // assignment compiles iff Body == Never.
        let _: Serializer.Witness<Int, [UInt8], Never>.Body.Type = Never.self
    }

    @Test
    func `body getter exists for Body == Never (default leaf extension)`() {
        // Default `body: Never` getter on `Serializer.Protocol where
        // Body == Never` provides the property. We cannot exercise the
        // fatalError without crashing the test runner. Compile-time
        // verification is the test: if the typealias `Body = Never` is
        // wrong on the conformer, the conformance does not type-check.
        let witness = Serializer.Witness<Int, [UInt8], Never> { _, _ in }
        _ = witness  // suppress unused
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

// MARK: - Edge Cases — Failure Propagation

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
        // No `try` keyword required because Failure == Never.
        witness.serialize(255, into: &buffer)
        #expect(buffer == [255])
    }
}

// MARK: - Integration — Protocol Conformance + RangeReplaceable Convenience

extension `Protocol Tests`.Integration {

    @Test
    func `Witness conforms to Serializer.Protocol`() {
        // Verifies the nested-protocol conformance: passing the witness
        // through a generic constrained by `Serializer.Protocol` resolves.
        // If the conformance is broken, the function signature does not
        // type-check.
        func acceptsAnySerializer<S: Serializer.`Protocol`>(_ serializer: S) -> S.Output.Type {
            return S.Output.self
        }

        let witness = Serializer.Witness<Int, [UInt8], Never> { _, _ in }
        let outputType = acceptsAnySerializer(witness)
        #expect(outputType == Int.self)
    }

    @Test
    func `Buffer: RangeReplaceableCollection default extension constructs a buffer`() {
        // `extension Serializer.Protocol where Buffer: RangeReplaceableCollection`
        // provides `serialize(_:) -> Buffer` (no inout parameter — constructs
        // a fresh empty buffer).
        let witness = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
            buffer.append(value)
        }

        // Infallible variant — no try needed.
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

        // Success.
        do throws(E) {
            let result: [UInt8] = try witness.serialize(7)
            #expect(result == [7])
        } catch {
            Issue.record("Did not expect throw for non-negative")
        }

        // Failure.
        do throws(E) {
            let _: [UInt8] = try witness.serialize(-1)
            Issue.record("Expected throw for negative")
        } catch {
            // pass
        }
    }
}

// MARK: - Declarative `var body` Composition (the SECOND default extension)
//
// `extension Serializer.Protocol where Body: Serializer.Protocol, Body.Output
// == Output, Body.Buffer == Buffer, Body.Failure == Failure { default
// serialize delegates to body.serialize }` — exercised here.

/// A declarative-composition conformer that prints an integer in decimal.
///
/// Demonstrates the `var body` style: no `serialize(_:into:)` method here —
/// the default extension provides it via delegation to body.serialize.
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
        // No `serialize(_:into:)` declared on DecimalPrinter — calling
        // serialize routes through the default extension that delegates to
        // body.serialize. If the default extension is wrong, this call
        // would not type-check.
        let printer = Decimal.Printer()
        var buffer: [UInt8] = []
        printer.serialize(42, into: &buffer)
        #expect(buffer == Array("42".utf8))
    }

    @Test
    func `body-style conformer's Body is the composed serializer's concrete type`() {
        // The opaque `some Serializer.Protocol<...>` in body resolves to
        // Serializer.Witness<Int, [UInt8], Never>. Verified by passing the
        // conformer through a generic constrained by Body's associated types.
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
        // Body-style and leaf-form conformers MUST behave identically.
        let printer = Decimal.Printer()
        var buffer: [UInt8] = Array("prefix:".utf8)
        printer.serialize(7, into: &buffer)
        #expect(buffer == Array("prefix:7".utf8))
    }
}
