//
//  Serializer.Many.Separated.swift
//  swift-serializer-primitives
//
//  Repetition serializer with separators.
//

public import Either_Primitives

extension Serializer.Many {
    /// A serializer that applies another serializer repeatedly with separators.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Comma-separated values
    /// let csv = Serializer.Many.Separated {
    ///     Field()
    /// } separator: {
    ///     ","
    /// }
    ///
    /// // One or more with separator
    /// let list = Serializer.Many.Separated(1...) {
    ///     IntSerializer()
    /// } separator: {
    ///     ","
    /// }
    /// ```
    ///
    /// ## Shared generics
    ///
    /// `Buffer` and `Element` are inherited from the outer ``Serializer/Many``;
    /// only the `Separator` parameter is added at this nesting level.
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

        /// `Int.max` means no maximum.
        @usableFromInline
        let maximum: Int

        /// Creates a separated repetition serializer accepting at least the range's lower bound.
        ///
        /// - Parameters:
        ///   - range: The minimum element count; the maximum is unbounded.
        ///   - element: A builder producing the per-element serializer.
        ///   - separator: A builder producing the between-elements separator serializer.
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

        /// Creates a separated repetition serializer whose element count falls within the range.
        ///
        /// - Parameters:
        ///   - range: The inclusive bounds on the element count.
        ///   - element: A builder producing the per-element serializer.
        ///   - separator: A builder producing the between-elements separator serializer.
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

        /// Creates a separated repetition serializer accepting zero or more elements.
        ///
        /// - Parameters:
        ///   - element: A builder producing the per-element serializer.
        ///   - separator: A builder producing the between-elements separator serializer.
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
    /// An array of the element serializer's output values.
    public typealias Output = [Element.Output]

    /// A count-bound error, or an element- or separator-serialization error.
    public typealias Failure = Either<Serializer.Many<Buffer, Element>.Error, Either<Element.Failure, Separator.Failure>>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes each element in order with separators between, enforcing the count bounds.
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
