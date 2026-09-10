#if Optic
import Either
import Optic
import Serializer
import Testing

@Suite
struct `Optic Serializer Tests` {

    @Test
    func `maps backward through an Isomorphism`() {
        let serializer = Text().map(backward: textWrapper)

        var buffer: [UInt8] = []
        serializer.serialize(TextValue(rawValue: "42"), into: &buffer)

        #expect(buffer == Array("42".utf8))
    }

    @Test
    func `maps backward through a total Adapter`() {
        let serializer = Text().map(backward: totalAdapter)

        var buffer: [UInt8] = []
        serializer.serialize(7, into: &buffer)

        #expect(buffer == Array("7".utf8))
    }

    @Test
    func `maps backward through a partial Adapter`() throws(any Swift.Error) {
        let serializer = Text().map(backward: nonNegativeAdapter)

        var buffer: [UInt8] = []
        try serializer.serialize(7, into: &buffer)

        #expect(buffer == Array("7".utf8))
    }

    @Test
    func `surfaces a partial Adapter's backward failure`() {
        let serializer = Text().map(backward: nonNegativeAdapter)

        var buffer: [UInt8] = []
        do {
            try serializer.serialize(-1, into: &buffer)
            Issue.record("Expected the backward direction to fail")
        } catch {
            switch error {
            case .left:
                Issue.record("Expected a right failure")
            case .right(let backward):
                #expect(backward == .negative)
            }
        }
        #expect(buffer.isEmpty)
    }

    @Test
    func `embeds through a Prism`() {
        let serializer = NodeText().map(embedding: leaf)

        var buffer: [UInt8] = []
        serializer.serialize(3, into: &buffer)

        #expect(buffer == Array("leaf(3)".utf8))
    }

    @Test
    func `matches through a Prism into an Either output`() {
        let serializer = BranchText().map(matching: leaf)

        var buffer: [UInt8] = []
        serializer.serialize(.leaf(5), into: &buffer)

        #expect(buffer == Array("right(5)".utf8))
    }

    @Test
    func `matches through a Prism and fails on a mismatch`() throws(any Swift.Error) {
        let serializer = Decimal().map(matching: leaf, failure: MatchFailure.mismatch)

        var buffer: [UInt8] = []
        try serializer.serialize(.leaf(9), into: &buffer)

        #expect(buffer == Array("9".utf8))

        do {
            try serializer.serialize(.empty, into: &buffer)
            Issue.record("Expected the match to fail")
        } catch {
            switch error {
            case .left:
                Issue.record("Expected a right failure")
            case .right(.mismatch(let node)):
                #expect(node == .empty)
            }
        }
    }
}

private enum Node: Equatable {
    case leaf(Int)
    case empty
}

private enum MatchFailure: Error {
    case mismatch(Node)
}

private enum BackwardFailure: Error, Equatable {
    case negative
}

private struct TextValue { let rawValue: String }

private var textWrapper: Optic<String, String, TextValue, TextValue>.Isomorphism {
    .init(forward: { TextValue(rawValue: $0) }, backward: { $0.rawValue })
}

private var totalAdapter: Optic<String, String, Int, Int>.Adapter<Never, Never> {
    Optic<String, String, Int, Int>.Adapter<Never, Never>(
        forward: { Int($0) ?? 0 },
        backward: { String($0) }
    )
}

private var nonNegativeAdapter: Optic<String, String, Int, Int>.Adapter<Never, BackwardFailure> {
    Optic<String, String, Int, Int>
        .Adapter<Never, BackwardFailure>(
            forward: { Int($0) ?? 0 },
            backward: { value throws(BackwardFailure) in
                guard value >= 0 else { throw .negative }
                return String(value)
            }
        )
}

private var leaf: Optic<Node, Node, Int, Int>.Prism {
    Optic<Node, Node, Int, Int>.Prism(
        embed: Node.leaf,
        extract: { node in
            guard case .leaf(let value) = node else { return nil }
            return value
        }
    )
}

private func describe(_ node: Node) -> String {
    switch node {
    case .leaf(let value):
        "leaf(\(value))"
    case .empty:
        "empty"
    }
}

private struct Text: Serializing {
    typealias Output = String
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: String, into buffer: inout [UInt8]) {
        buffer.append(contentsOf: output.utf8)
    }
}

private struct Decimal: Serializing {
    typealias Output = Int
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: Int, into buffer: inout [UInt8]) {
        buffer.append(contentsOf: String(output).utf8)
    }
}

private struct NodeText: Serializing {
    typealias Output = Node
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: Node, into buffer: inout [UInt8]) {
        buffer.append(contentsOf: describe(output).utf8)
    }
}

private struct BranchText: Serializing {
    typealias Output = Either<Node, Int>
    typealias Buffer = [UInt8]
    typealias Failure = Never

    borrowing func serialize(_ output: Either<Node, Int>, into buffer: inout [UInt8]) {
        switch output {
        case .left(let node):
            buffer.append(contentsOf: "left(\(describe(node)))".utf8)
        case .right(let value):
            buffer.append(contentsOf: "right(\(value))".utf8)
        }
    }
}

#endif
