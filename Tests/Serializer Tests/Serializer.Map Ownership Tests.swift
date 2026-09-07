import Either
import Serializer
import Testing

@Suite
struct `Serializer mapping preserves its owned resource` {
    @Test
    func `a noncopyable leaf borrows execution and retains partial writes on failure`() throws {
        let lifetime = Lifetime()
        let serializer = Owned(lifetime: lifetime)
        var buffer = Buffer()
        try serializer.serialize(1, into: &buffer)
        do throws(Owned.Error) {
            try serializer.serialize(2, into: &buffer)
            Issue.record("The leaf unexpectedly accepted the rejected value")
        } catch {
            #expect(error == .rejected(2))
        }
        #expect(buffer.values == [1, 2])
        #expect(lifetime.destroyed == 0)
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `explicit error transforms compose noncopyable owners and preserve partial writes`() throws {
        let lifetime = Lifetime()
        let firstMap = Serializer.Error.Transform(Owned(lifetime: lifetime)).map { error -> Mapped in
            lifetime.mapped += 1
            return .upstream(error)
        }
        let serializer = Serializer.Error.Transform(firstMap).map { error -> Mapped in error }
        requireFailure(serializer, Mapped.self)
        var buffer = Buffer()
        try serializer.serialize(1, into: &buffer)
        #expect(lifetime.mapped == 0)
        do throws(Mapped) {
            try serializer.serialize(2, into: &buffer)
            Issue.record("The mapped serializer unexpectedly accepted the rejected value")
        } catch {
            #expect(error == .upstream(.rejected(2)))
        }
        try serializer.serialize(3, into: &buffer)
        #expect(buffer.values == [1, 2, 3])
        #expect(lifetime.mapped == 1)
        #expect(lifetime.destroyed == 0)
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `total contramap borrows noncopyable values and preserves upstream failure`() throws {
        let lifetime = Lifetime()
        let serializer = Owned(lifetime: lifetime).contramap { (value: borrowing Value) in value.number }
        requireFailure(serializer, Owned.Error.self)
        let first = Value(number: 1)
        let rejected = Value(number: 2)
        var buffer = Buffer()
        try serializer.serialize(first, into: &buffer)
        do throws(Owned.Error) {
            try serializer.serialize(rejected, into: &buffer)
            Issue.record("Contramap unexpectedly accepted the rejected value")
        } catch {
            #expect(error == .rejected(2))
        }
        #expect(first.number == 1 && rejected.number == 2)
        #expect(buffer.values == [1, 2])
        #expect(lifetime.destroyed == 0)
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `throwing contramap preserves both failure branches and remains usable after failure`() throws {
        let lifetime = Lifetime()
        let serializer = Owned(lifetime: lifetime).contramap(transform)
        requireFailure(serializer, Either<Owned.Error, TransformError>.self)
        let invalid = Value(number: -1)
        let rejected = Value(number: 2)
        let accepted = Value(number: 3)
        var buffer = Buffer()
        do throws(Either<Owned.Error, TransformError>) {
            try serializer.serialize(invalid, into: &buffer)
            Issue.record("The value transform unexpectedly succeeded")
        } catch {
            #expect(error == .right(.negative(-1)))
        }
        #expect(buffer.values.isEmpty)
        #expect(lifetime.calls == 0)
        do throws(Either<Owned.Error, TransformError>) {
            try serializer.serialize(rejected, into: &buffer)
            Issue.record("The upstream serializer unexpectedly succeeded")
        } catch {
            #expect(error == .left(.rejected(2)))
        }
        try serializer.serialize(accepted, into: &buffer)
        #expect(buffer.values == [2, 3])
        #expect(lifetime.calls == 2)
        #expect(invalid.number == -1 && rejected.number == 2 && accepted.number == 3)
        #expect(lifetime.destroyed == 0)
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `error mapping composes with a throwing contramap without copying the owner`() throws {
        let lifetime = Lifetime()
        let upstream = Owned(lifetime: lifetime).contramap(transform)
        let serializer = Serializer.Error.Transform(upstream).map { Mapped.composition($0) }
        let invalid = Value(number: -1)
        let accepted = Value(number: 3)
        var buffer = Buffer()
        do throws(Mapped) {
            try serializer.serialize(invalid, into: &buffer)
            Issue.record("The composed transform unexpectedly succeeded")
        } catch {
            #expect(error == .composition(.right(.negative(-1))))
        }
        try serializer.serialize(accepted, into: &buffer)
        #expect(buffer.values == [3])
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `contramap borrows a scoped input while mutating a noncopyable buffer`() throws {
        let lifetime = Lifetime()
        let serializer = Owned(lifetime: lifetime).contramap { (span: borrowing Span<Int>) in span[0] }
        let values = [3, 4]
        var buffer = Buffer()
        try serializer.serialize(values.span, into: &buffer)
        #expect(buffer.values == [3])
        #expect(values == [3, 4])
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `fluent error access and maps stay copyable with copyable owners`() throws {
        let upstream = Serializer.Witness<Int, Buffer, Owned.Error> { value, buffer in
            buffer.values.append(value)
        }
        let errors = upstream.error
        requireCopyable(errors)
        let mappedErrors = errors.map { Mapped.upstream($0) }
        requireCopyable(mappedErrors)
        let total = upstream.contramap { (value: borrowing Value) in value.number }
        requireCopyable(total)
        let throwing = upstream.contramap(transform)
        requireCopyable(throwing)
        let value = Value(number: 3)
        var buffer = Buffer()
        try upstream.serialize(1, into: &buffer)
        try mappedErrors.serialize(2, into: &buffer)
        try total.serialize(value, into: &buffer)
        try throwing.serialize(value, into: &buffer)
        #expect(buffer.values == [1, 2, 3, 3])
    }
}

private func transform(_ value: borrowing Value) throws(TransformError) -> Int {
    guard value.number >= 0 else { throw .negative(value.number) }
    return value.number
}

private func requireFailure<S: Serializer.`Protocol` & ~Copyable, E: Swift.Error>(
    _: borrowing S,
    _: E.Type
) where S.Output: ~Copyable & ~Escapable, S.Buffer: ~Copyable & ~Escapable, S.Failure == E {}

private func requireCopyable<T: Copyable>(_: T) {}

private func discard<T: ~Copyable>(_ value: consuming T) {}

private enum TransformError: Swift.Error, Equatable {
    case negative(Int)
}

private enum Mapped: Swift.Error, Equatable {
    case upstream(Owned.Error)
    case composition(Either<Owned.Error, TransformError>)
}

private struct Value: ~Copyable {
    let number: Int
}

private struct Buffer: ~Copyable {
    var values: [Int] = []
}

private final class Lifetime {
    var destroyed = 0
    var calls = 0
    var mapped = 0
}

private struct Owned: ~Copyable, Serializer.`Protocol` {
    let lifetime: Lifetime

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    deinit { lifetime.destroyed += 1 }

    borrowing func serialize(_ output: Int, into buffer: inout Buffer) throws(Error) {
        lifetime.calls += 1
        buffer.values.append(output)
        guard output != 2 else { throw .rejected(output) }
    }
}
