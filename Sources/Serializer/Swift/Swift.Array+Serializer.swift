extension Swift.Array {

    public struct Serializer<Buffer: RangeReplaceableCollection>: Serializer::Serializing
    where Buffer.Element == Element {
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf serializer: implement serialize(_:into:) directly")
            }
        }


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
