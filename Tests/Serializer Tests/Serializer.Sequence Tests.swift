import Serializer
import Testing

@Suite struct `Sequence Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Sequence Tests`.Unit {

    @Test
    func `Sequence.Two writes both serializers into the same buffer`() {
        let s1 = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value))
        }
        let s2 = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value &+ 100))
        }

        let pair = Serializer.Sequence.Two(s1, s2)
        var buffer: [UInt8] = []
        do throws(Either<Never, Never>) {
            try pair.serialize(1, into: &buffer)
            #expect(buffer == [1, 101])
        } catch {
            Issue.record("Did not expect throw")
        }
    }

    @Test
    func `Sequence.Two preserves write order`() {
        let s1 = Serializer.Witness<Int, [UInt8], Never> { v, b in b.append(UInt8(v)) }
        let s2 = Serializer.Witness<Int, [UInt8], Never> { v, b in b.append(UInt8(v &+ 10)) }

        let pair = Serializer.Sequence.Two(s1, s2)
        var buffer: [UInt8] = [99]
        do throws(Either<Never, Never>) {
            try pair.serialize(5, into: &buffer)
            #expect(buffer == [99, 5, 15])
        } catch {
            Issue.record("Did not expect throw")
        }
    }
}

extension `Sequence Tests`.`Edge Case` {

    @Test
    func `Sequence.Two surfaces left failure when first serializer throws`() {
        struct E0: Swift.Error, Equatable {}
        struct E1: Swift.Error, Equatable {}

        let s1 = Serializer.Witness<Int, [UInt8], E0> { _, _ throws(E0) in throw E0() }
        let s2 = Serializer.Witness<Int, [UInt8], E1> { v, b throws(E1) in b.append(UInt8(v)) }

        let pair = Serializer.Sequence.Two(s1, s2)
        var buffer: [UInt8] = []
        do throws(Either<E0, E1>) {
            try pair.serialize(1, into: &buffer)
            Issue.record("Expected throw")
        } catch let error {
            switch error {
            case .left(let e0):
                #expect(e0 == E0())

            case .right:
                Issue.record("Expected .left, got .right")
            }
        }
    }

    @Test
    func `Sequence.Two surfaces right failure when second serializer throws`() {
        struct E0: Swift.Error, Equatable {}
        struct E1: Swift.Error, Equatable {}

        let s1 = Serializer.Witness<Int, [UInt8], E0> { v, b throws(E0) in b.append(UInt8(v)) }
        let s2 = Serializer.Witness<Int, [UInt8], E1> { _, _ throws(E1) in throw E1() }

        let pair = Serializer.Sequence.Two(s1, s2)
        var buffer: [UInt8] = []
        do throws(Either<E0, E1>) {
            try pair.serialize(1, into: &buffer)
            Issue.record("Expected throw")
        } catch let error {
            switch error {
            case .right(let e1):
                #expect(e1 == E1())

            case .left:
                Issue.record("Expected .right, got .left")
            }
        }
    }
}

extension `Sequence Tests`.Unit {

    @Test
    func `Sequence.Three writes all three serializers into the same buffer`() {
        let s1 = Serializer.Witness<Int, [UInt8], Never> { v, b in b.append(UInt8(v)) }
        let s2 = Serializer.Witness<Int, [UInt8], Never> { v, b in b.append(UInt8(v &+ 10)) }
        let s3 = Serializer.Witness<Int, [UInt8], Never> { v, b in b.append(UInt8(v &+ 20)) }

        let triple = Serializer.Sequence.Three(s1, s2, s3)
        var buffer: [UInt8] = []
        do throws(Either<Never, Either<Never, Never>>) {
            try triple.serialize(1, into: &buffer)
            #expect(buffer == [1, 11, 21])
        } catch {
            Issue.record("Did not expect throw")
        }
    }
}

enum Duo {}

extension Duo {
    struct Printer {}
}

extension Duo.Printer: Serializer.`Protocol` {
    typealias Output = Int
    typealias Buffer = [UInt8]
    typealias Failure = Either<Never, Never>

    var body: some Serializer.`Protocol`<Int, [UInt8], Failure> {
        Serializer.Witness<Int, [UInt8], Never> { v, b in
            b.append(UInt8(truncatingIfNeeded: v))
        }
        Serializer.Witness<Int, [UInt8], Never> { v, b in
            b.append(UInt8(truncatingIfNeeded: v &+ 100))
        }
    }
}

extension `Sequence Tests`.Integration {

    @Test
    func `var body with two serializers builds Sequence.Two via buildBlock`() {
        let printer = Duo.Printer()
        var buffer: [UInt8] = []
        do throws(Duo.Printer.Failure) {
            try printer.serialize(1, into: &buffer)
            #expect(buffer == [1, 101])
        } catch {
            Issue.record("Did not expect throw")
        }
    }
}
