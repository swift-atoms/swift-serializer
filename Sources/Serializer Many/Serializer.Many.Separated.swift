public import Either

extension Serializer.Many {

    public struct Separated<Separator: Serializer.`Protocol`>
    where
        Separator.Buffer == Buffer,
        Separator.Output == Void
    {
        @usableFromInline
        let element: Element

        @usableFromInline
        let separator: Separator

        @usableFromInline
        let minimum: Int

        @usableFromInline
        let maximum: Int

        @inlinable
        public init(
            _ range: PartialRangeFrom<Int>,
            @Serializer.Builder<Buffer> element: () -> Element,
            @Serializer.Builder<Buffer> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = range.lowerBound
            self.maximum = .max
        }

        @inlinable
        public init(
            _ range: ClosedRange<Int>,
            @Serializer.Builder<Buffer> element: () -> Element,
            @Serializer.Builder<Buffer> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = range.lowerBound
            self.maximum = range.upperBound
        }

        @inlinable
        public init(
            @Serializer.Builder<Buffer> element: () -> Element,
            @Serializer.Builder<Buffer> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = 0
            self.maximum = .max
        }
    }
}

extension Serializer.Many.Separated: Serializer.`Protocol` {

    public typealias Output = [Element.Output]

    public typealias Failure = Either<
        Serializer.Many<Buffer, Element>.Error, Either<Element.Failure, Separator.Failure>
    >

    public typealias Body = Never

    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        if output.count < minimum {
            throw .left(.countTooLow(expected: minimum, got: output.count))
        }
        if maximum < .max, output.count > maximum {
            throw .left(.countTooHigh(expected: maximum, got: output.count))
        }

        var isFirst = true
        for item in output {
            if !isFirst {
                do throws(Separator.Failure) {
                    try separator.serialize((), into: &buffer)
                } catch {
                    throw .right(.right(error))
                }
            }
            do throws(Element.Failure) {
                try element.serialize(item, into: &buffer)
            } catch {
                throw .right(.left(error))
            }
            isFirst = false
        }
    }
}
