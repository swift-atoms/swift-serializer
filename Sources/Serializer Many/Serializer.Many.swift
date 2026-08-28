public import Either

extension Serializer {

    public struct Many<Buffer, Element: Serializer.`Protocol`>
    where Element.Buffer == Buffer {
        @usableFromInline
        let element: Element

        @usableFromInline
        let minimum: Int

        @usableFromInline
        let maximum: Int

        @inlinable
        public init(
            _ range: PartialRangeFrom<Int>,
            @Serializer.Builder<Buffer> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = .max
        }

        @inlinable
        public init(
            _ range: ClosedRange<Int>,
            @Serializer.Builder<Buffer> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = range.upperBound
        }

        @inlinable
        public init(
            @Serializer.Builder<Buffer> element: () -> Element
        ) {
            self.element = element()
            self.minimum = 0
            self.maximum = .max
        }
    }
}

extension Serializer.Many: Serializer.`Protocol` {

    public typealias Output = [Element.Output]

    public typealias Failure = Either<Serializer.Many<Buffer, Element>.Error, Element.Failure>

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        if output.count < minimum {
            throw .left(.countTooLow(expected: minimum, got: output.count))
        }
        if maximum < .max, output.count > maximum {
            throw .left(.countTooHigh(expected: maximum, got: output.count))
        }

        for item in output {
            do throws(Element.Failure) {
                try element.serialize(item, into: &buffer)
            } catch {
                throw .right(error)
            }
        }
    }
}
