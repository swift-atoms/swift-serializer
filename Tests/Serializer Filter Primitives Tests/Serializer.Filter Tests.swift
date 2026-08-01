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
// target covers ONLY the `Serializer Filter Primitives` source target —
// `Serializer.Filter` and the `.filter(_:)` extension method.
//
// `Serializer.Filter<Upstream>` is a generic type, so its test suite cannot
// be attached via `extension Serializer.Filter { @Suite ... }` — that shape
// either hard-errors (unspecialized) or compiles but is silently never
// discovered (specialized). Per the testing skill's "host types that break
// the extension pattern" guidance, this uses a top-level backticked suite.

import Serializer_Filter_Primitives
import Serializer_Witness_Primitives
import Testing

// MARK: - Test Suite Structure

@Suite struct `Filter Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Filter Tests`.Unit {

    @Test
    func `Filter delegates when predicate accepts the value`() {
        let upstream = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let filtered = upstream.filter { $0 >= 0 }

        var buffer: [UInt8] = []
        do throws(Serializer.Filter<Serializer.Witness<Int, [UInt8], Never>>.Failure) {
            try filtered.serialize(42, into: &buffer)
            #expect(buffer == [42])
        } catch {
            Issue.record("Did not expect throw for accepted value")
        }
    }

    @Test
    func `Filter rejects when predicate fails — throws Either.right(.validationFailed)`() {
        let upstream = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let filtered = upstream.filter { $0 >= 0 }

        var buffer: [UInt8] = []
        do throws(Serializer.Filter<Serializer.Witness<Int, [UInt8], Never>>.Failure) {
            try filtered.serialize(-1, into: &buffer)
            Issue.record("Expected predicate rejection")
        } catch let error {
            switch error {
            case .right(let filterError):
                if case .validationFailed = filterError {
                    // expected
                } else {
                    Issue.record("Expected .validationFailed")
                }

            case .left:
                Issue.record("Expected .right (filter error), got .left (upstream error)")
            }
        }
        #expect(buffer.isEmpty)  // predicate failed before any write
    }
}

// MARK: - Edge Cases

extension `Filter Tests`.`Edge Case` {

    @Test
    func `Filter wraps upstream failure as Either.left`() {
        struct Failing: Swift.Error, Equatable {}

        let upstream = Serializer.Witness<Int, [UInt8], Failing> { _, _ throws(Failing) in
            throw Failing()
        }

        let filtered = upstream.filter { _ in true }  // always accepts

        var buffer: [UInt8] = []
        do throws(Serializer.Filter<Serializer.Witness<Int, [UInt8], Failing>>.Failure) {
            try filtered.serialize(0, into: &buffer)
            Issue.record("Expected upstream error")
        } catch let error {
            switch error {
            case .left(let upstreamE):
                #expect(upstreamE == Failing())

            case .right:
                Issue.record("Expected .left (upstream error), got .right (filter error)")
            }
        }
    }
}

// MARK: - Integration — `var body` with .filter

/// Namespace for the non-empty-string integration fixture.
enum Populated {}

extension Populated {
    /// Serializes a non-empty String to its UTF-8 bytes; throws if empty.
    ///
    /// Demonstrates `var body` with a `.filter` chain on a leaf serializer.
    struct Printer {}
}

extension Populated.Printer: Serializer.`Protocol` {
    typealias Output = String
    typealias Buffer = [UInt8]
    typealias Failure = Either<Never, Serializer.Filter<Serializer.Witness<String, [UInt8], Never>>.Error>

    var body: some Serializer.`Protocol`<String, [UInt8], Failure> {
        Serializer.Witness<String, [UInt8], Never> { value, buffer in
            buffer.append(contentsOf: value.utf8)
        }
        .filter { !$0.isEmpty }
    }
}

extension `Filter Tests`.Integration {

    @Test
    func `var body with .filter writes through when predicate passes`() {
        let printer = Populated.Printer()
        var buffer: [UInt8] = []
        do throws(Populated.Printer.Failure) {
            try printer.serialize("hello", into: &buffer)
            #expect(buffer == Array("hello".utf8))
        } catch {
            Issue.record("Did not expect throw for non-empty string")
        }
    }

    @Test
    func `var body with .filter rejects empty string`() {
        let printer = Populated.Printer()
        var buffer: [UInt8] = []
        do throws(Populated.Printer.Failure) {
            try printer.serialize("", into: &buffer)
            Issue.record("Expected empty-string rejection")
        } catch {
            // expected — predicate fails on empty string
        }
        #expect(buffer.isEmpty)
    }
}
