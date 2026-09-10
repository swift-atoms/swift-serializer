#if Repetition
import Serializer
import Testing

@Suite struct `Repeated serialization validates bounds before writes` {
    @Test func `empty cardinal bounds reject even an empty array`() {
        let serializer = Repetition(Cardinal.zero..<Cardinal.zero, operation: Element()).serializer()
        var buffer = [9]
        #expect(throws: Either<Repetition<Range<Cardinal>, Element>.Error, ElementError>.left(.emptyBounds)) {
            try serializer.serialize([], into: &buffer)
        }
        #expect(buffer == [9])
    }

    @Test func `minimum and exclusive maximum preserve exact cardinal failures`() {
        let serializer = Repetition(Cardinal(2)..<Cardinal(4), operation: Element()).serializer()
        var buffer = [9]
        #expect(throws: Either<Repetition<Range<Cardinal>, Element>.Error, ElementError>.left(.insufficient(actual: 1))) {
            try serializer.serialize([1], into: &buffer)
        }
        #expect(throws: Either<Repetition<Range<Cardinal>, Element>.Error, ElementError>.left(.excessive(actual: 4))) {
            try serializer.serialize([1, 2, 3, 4], into: &buffer)
        }
        #expect(buffer == [9])
    }

    @Test func `separated count validation precedes every write`() {
        let serializer = Repetition(Cardinal(1)...Cardinal(2), operation: Element()).serializer(separator: Separator())
        var buffer = [9]
        #expect(throws: Either<Repetition<ClosedRange<Cardinal>, Element>.Error, Either<ElementError, Never>>.left(.excessive(actual: 3))) {
            try serializer.serialize([1, 2, 3], into: &buffer)
        }
        #expect(buffer == [9])
    }

    @Test func `empty and singleton arrays never emit a separator`() throws {
        let serializer = Repetition(Cardinal.zero..., operation: Element()).serializer(separator: FailingSeparator())
        var buffer: [Int] = []
        try serializer.serialize([], into: &buffer)
        try serializer.serialize([3], into: &buffer)
        #expect(buffer == [3])
    }

    @Test func `separator and element failures propagate with partial writes`() {
        let separatorFailure = Repetition(Cardinal.zero..., operation: Element()).serializer(separator: FailingSeparator())
        var first: [Int] = []
        #expect(throws: Either<Repetition<PartialRangeFrom<Cardinal>, Element>.Error, Either<ElementError, SeparatorError>>.right(.right(.failed))) {
            try separatorFailure.serialize([1, 2], into: &first)
        }
        #expect(first == [1, 99])

        let elementFailure = Repetition(Cardinal.zero..., operation: Element()).serializer(separator: Separator())
        var second: [Int] = []
        #expect(throws: Either<Repetition<PartialRangeFrom<Cardinal>, Element>.Error, Either<ElementError, Never>>.right(.left(.rejected))) {
            try elementFailure.serialize([1, -1, 3], into: &second)
        }
        #expect(second == [1, 0, -1])
    }

    @Test func `noncopyable repeated owner and buffer are preserved`() throws {
        let lifetime = Lifetime()
        let serializer = Repetition(Cardinal.zero..., operation: OwnedElement(lifetime: lifetime)).serializer()
        var buffer = OwnedBuffer()
        try serializer.serialize([1, 2], into: &buffer)
        try serializer.serialize([3], into: &buffer)
        #expect(buffer.values == [1, 2, 3])
        #expect(lifetime.destroyed == 0)
        discard(serializer)
        #expect(lifetime.destroyed == 1)
    }
}

private enum ElementError: Error, Equatable { case rejected }
private enum SeparatorError: Error, Equatable { case failed }
private struct Element: Serializing {
    borrowing func serialize(_ output: Int, into buffer: inout [Int]) throws(ElementError) {
        buffer.append(output)
        guard output >= 0 else { throw .rejected }
    }
}
private struct Separator: Serializing {
    borrowing func serialize(_ output: Void, into buffer: inout [Int]) { buffer.append(0) }
}
private struct FailingSeparator: Serializing {
    borrowing func serialize(_ output: Void, into buffer: inout [Int]) throws(SeparatorError) {
        buffer.append(99)
        throw .failed
    }
}
private final class Lifetime { var destroyed = 0 }
private struct OwnedBuffer: ~Copyable { var values: [Int] = [] }
private struct OwnedElement: Serializing, ~Copyable {
    let lifetime: Lifetime
    deinit { lifetime.destroyed += 1 }
    borrowing func serialize(_ output: Int, into buffer: inout OwnedBuffer) { buffer.values.append(output) }
}
private func discard<T: ~Copyable>(_ value: consuming T) {}
#endif

#if Repetition
extension `Repeated serialization validates bounds before writes` {
    @Test func `separated repetition owns both noncopyable serializers`() throws {
        let elementLifetime = Lifetime()
        let separatorLifetime = Lifetime()
        let serializer = Repetition(Cardinal.zero..., operation: OwnedElement(lifetime: elementLifetime))
            .serializer(separator: OwnedSeparator(lifetime: separatorLifetime))
        var buffer = OwnedBuffer()
        try serializer.serialize([1, 2], into: &buffer)
        #expect(buffer.values == [1, 0, 2])
        #expect(elementLifetime.destroyed == 0 && separatorLifetime.destroyed == 0)
        discard(serializer)
        #expect(elementLifetime.destroyed == 1 && separatorLifetime.destroyed == 1)
    }
}
private struct OwnedSeparator: Serializing, ~Copyable {
    let lifetime: Lifetime
    deinit { lifetime.destroyed += 1 }
    borrowing func serialize(_ output: Void, into buffer: inout OwnedBuffer) { buffer.values.append(0) }
}
#endif
