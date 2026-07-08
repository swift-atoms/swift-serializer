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
// target covers ONLY the `Serializer Namespace` source target — the enum
// namespace and the closure-backed ``Serializer/Witness`` storage (its init
// and `_serialize` storage). The witness behavior under conformance
// (``Serializer/Protocol``, default extensions, body delegation) is provided
// by `Serializer Primitives Core` and tested in
// `Serializer Primitives Core Tests`.

import Serializer_Primitive
import Serializer_Witness_Primitives
import Testing

// MARK: - Test Suite Structure

/// Test namespace for the ``Serializer/Witness`` storage declared in the
/// `Serializer Namespace` source target.
enum SerializerWitnessTests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension SerializerWitnessTests.Unit {

    @Test
    func `init stores the serialize closure`() {
        // Construct the witness and verify the public `_serialize` storage
        // holds the closure passed at init. Pure Namespace-target surface:
        // does NOT invoke `.serialize(_:into:)` (which is the Core
        // conformance method tested separately).
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

// MARK: - Edge Cases

extension SerializerWitnessTests.`Edge Case` {

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
        struct ZeroIsForbidden: Swift.Error, Equatable {}

        let witness = Serializer.Witness<Int, [UInt8], ZeroIsForbidden> { value, buffer throws(ZeroIsForbidden) in
            guard value != 0 else { throw ZeroIsForbidden() }
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        var buffer: [UInt8] = []
        do throws(ZeroIsForbidden) {
            try witness._serialize(7, &buffer)
            #expect(buffer == [7])
        } catch {
            Issue.record("Did not expect throw for non-zero")
        }

        do throws(ZeroIsForbidden) {
            try witness._serialize(0, &buffer)
            Issue.record("Expected ZeroIsForbidden to be thrown")
        } catch {
            #expect(error == ZeroIsForbidden())
        }
    }
}
