import Either
import Serializer
import Testing

@Suite struct `Map Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Map Tests`.Unit {

    @Test
    func `Map.Transform transforms new input then delegates to upstream`() {

        let upstream = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let mapped = upstream.map { (input: String) -> Int in
            input.count
        }

        var buffer: [UInt8] = []
        mapped.serialize("hello", into: &buffer)

        #expect(buffer == [5])
    }

    @Test
    func `Map.Transform.Failure equals Upstream.Failure (no failure introduced)`() {

        struct E: Swift.Error {}
        let upstream = Serializer.Witness<Int, [UInt8], E> { _, _ throws(E) in throw E() }
        let mapped = upstream.map { (s: String) -> Int in s.count }

        let _: E.Type = type(of: mapped).Failure.self
    }
}

extension `Map Tests`.Unit {

    @Test
    func `Map.Throwing wraps upstream Failure as Either.left, transform error as right`() {
        struct Upstream: Swift.Error {}
        struct Transformation: Swift.Error, Equatable {}

        let upstream = Serializer.Witness<Int, [UInt8], Upstream> {
            value,
            buffer throws(Upstream) in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        let mapped = upstream.tryMap { (input: String) throws(Transformation) -> Int in
            guard !input.isEmpty else { throw Transformation() }
            return input.count
        }

        var buffer: [UInt8] = []

        do throws(Serializer.Map<Serializer.Witness<Int, [UInt8], Upstream>, String>.Throwing<
            Transformation
        >.Failure) {
            try mapped.serialize("ok", into: &buffer)
            #expect(buffer == [2])
        } catch {
            Issue.record("Did not expect throw on success path")
        }

        buffer.removeAll()
        do throws(Serializer.Map<Serializer.Witness<Int, [UInt8], Upstream>, String>.Throwing<
            Transformation
        >.Failure) {
            try mapped.serialize("", into: &buffer)
            Issue.record("Expected Transformation")
        } catch let error {
            switch error {
            case .right:
                break

            case .left:
                Issue.record("Expected .right, got .left")
            }
        }
    }
}

enum Uppercased {}

extension Uppercased {
    struct Counter {}
}

extension Uppercased.Counter: Serializer.`Protocol` {
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

extension `Map Tests`.Integration {

    @Test
    func `var body with .map chain serializes via contravariant transform`() {
        let counter = Uppercased.Counter()
        var buffer: [UInt8] = []
        counter.serialize("ab", into: &buffer)

        #expect(buffer == [2])
    }

    @Test
    func `var body with .map appends, mirroring leaf-form behavior`() {
        let counter = Uppercased.Counter()
        var buffer: [UInt8] = [99]
        counter.serialize("hi", into: &buffer)

        #expect(buffer == [99, 2])
    }
}
