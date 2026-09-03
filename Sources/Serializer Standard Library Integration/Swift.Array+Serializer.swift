public import Serializer

extension Swift.Array {

    public struct Serializer<Buffer: RangeReplaceableCollection>: Serializer::Serializer.`Protocol`
    where Buffer.Element == Element {

        public typealias Output = Void

        public typealias Failure = Never

        public let elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self.elements = elements
        }

        @inlinable
        public borrowing func serialize(_ output: Void, into buffer: inout Buffer) {
            buffer.append(contentsOf: elements)
        }
    }
}
