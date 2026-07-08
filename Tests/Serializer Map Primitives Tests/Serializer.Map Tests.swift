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
// target covers ONLY the `Serializer Map Primitives` source target —
// `Serializer.Map.Transform`, `Serializer.Map.Throwing`, and the `.map(_:)`
// / `.tryMap(_:)` methods declared as extensions on Serializer.Protocol.
//
// Map is contravariant for serializers: `.map { newInput in upstream.Output }`
// transforms the NEW input into the upstream's expected output before
// delegating to upstream.serialize.

import Serializer_Map_Primitives
import Serializer_Witness_Primitives
import Testing

// MARK: - Test Suite Structure

enum MapTests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests — Map.Transform (Pure Contravariant Transform)

extension MapTests.Unit {

    @Test
    func `Map.Transform transforms new input then delegates to upstream`() {
        // Upstream serializes an Int as one byte. Map's transform takes a
        // String and produces the Int (Upstream.Output) the upstream
        // serializes.
        let upstream = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let mapped = upstream.map { (input: String) -> Int in
            input.count
        }

        var buffer: [UInt8] = []
        mapped.serialize("hello", into: &buffer)
        // .map transforms "hello" → 5 → upstream serializes 5
        #expect(buffer == [5])
    }

    @Test
    func `Map.Transform.Failure equals Upstream.Failure (no failure introduced)`() {
        // Pure (non-throwing) map does not add a failure layer.
        struct E: Swift.Error {}
        let upstream = Serializer.Witness<Int, [UInt8], E> { _, _ throws(E) in throw E() }
        let mapped = upstream.map { (s: String) -> Int in s.count }
        // Failure type is E, not Either<E, ...>.
        let _: E.Type = type(of: mapped).Failure.self
    }
}

// MARK: - Unit Tests — Map.Throwing (Failure-Adding Transform)

extension MapTests.Unit {

    @Test
    func `Map.Throwing wraps upstream Failure as Either.left, transform error as right`() {
        struct UpstreamE: Swift.Error {}
        struct TransformE: Swift.Error, Equatable {}

        let upstream = Serializer.Witness<Int, [UInt8], UpstreamE> { value, buffer throws(UpstreamE) in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let mapped = upstream.tryMap { (input: String) throws(TransformE) -> Int in
            guard !input.isEmpty else { throw TransformE() }
            return input.count
        }

        var buffer: [UInt8] = []

        // Success: transform succeeds, upstream succeeds.
        do throws(Serializer.Map<Serializer.Witness<Int, [UInt8], UpstreamE>, String>.Throwing<TransformE>.Failure) {
            try mapped.serialize("ok", into: &buffer)
            #expect(buffer == [2])
        } catch {
            Issue.record("Did not expect throw on success path")
        }

        // Transform failure: throw is .right(TransformE)
        buffer.removeAll()
        do throws(Serializer.Map<Serializer.Witness<Int, [UInt8], UpstreamE>, String>.Throwing<TransformE>.Failure) {
            try mapped.serialize("", into: &buffer)
            Issue.record("Expected TransformE")
        } catch let error {
            switch error {
            case .right:
                break  // expected — transform threw

            case .left:
                Issue.record("Expected .right, got .left")
            }
        }
    }
}

// MARK: - Integration — `var body` Composition with .map

/// Serializes a `String` as its UTF-8 byte count (uppercased input first).
///
/// Demonstrates `var body` with a `.map` chain on a leaf serializer. The
/// body composes a single chained expression and returns the
/// `Map.Transform` type.
struct UppercaseByteCounter: Serializer.`Protocol` {}

extension UppercaseByteCounter {
    typealias Output = String
    typealias Buffer = [UInt8]
    typealias Failure = Never

    var body: some Serializer.`Protocol`<String, [UInt8], Never> {
        Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }
        .map { (input: String) -> Int in
            input.uppercased().count
        }
    }
}

extension MapTests.Integration {

    @Test
    func `var body with .map chain serializes via contravariant transform`() {
        let counter = UppercaseByteCounter()
        var buffer: [UInt8] = []
        counter.serialize("ab", into: &buffer)
        // "ab" → uppercased "AB" → count 2 → upstream writes 2.
        #expect(buffer == [2])
    }

    @Test
    func `var body with .map appends, mirroring leaf-form behavior`() {
        let counter = UppercaseByteCounter()
        var buffer: [UInt8] = [99]
        counter.serialize("hi", into: &buffer)
        // Existing [99] preserved, then 2 appended.
        #expect(buffer == [99, 2])
    }
}
