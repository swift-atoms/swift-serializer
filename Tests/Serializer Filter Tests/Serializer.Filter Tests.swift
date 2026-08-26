import Serializer_Filter
import Serializer_Witness
import Testing

@Suite struct `Filter Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

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

                } else {
                    Issue.record("Expected .validationFailed")
                }

            case .left:
                Issue.record("Expected .right (filter error), got .left (upstream error)")
            }
        }
        #expect(buffer.isEmpty)
    }
}

extension `Filter Tests`.`Edge Case` {

    @Test
    func `Filter wraps upstream failure as Either.left`() {
        struct Failing: Swift.Error, Equatable {}

        let upstream = Serializer.Witness<Int, [UInt8], Failing> { _, _ throws(Failing) in
            throw Failing()
        }

        let filtered = upstream.filter { _ in true }

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

enum Populated {}

extension Populated {

    struct Printer {}
}

extension Populated.Printer: Serializer.`Protocol` {
    typealias Output = String
    typealias Buffer = [UInt8]
    typealias Failure = Either<
        Never, Serializer.Filter<Serializer.Witness<String, [UInt8], Never>>.Error
    >

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

        }
        #expect(buffer.isEmpty)
    }
}
