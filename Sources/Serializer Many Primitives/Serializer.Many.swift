//
//  Serializer.Many.swift
//  swift-serializer-primitives
//
//  Repetition — serialize a collection of elements zero or more times.
//

public import Either_Primitives

extension Serializer {
    /// A serializer that applies another serializer repeatedly (no separator).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Zero or more digits
    /// let digits = Serializer.Many { Digit() }
    ///
    /// // One or more digits
    /// let digits1 = Serializer.Many(1...) { Digit() }
    ///
    /// // Exactly 4 digits
    /// let pin = Serializer.Many(4...4) { Digit() }
    /// ```
    ///
    /// ## Separator variant
    ///
    /// For repetition with separators between elements, see
    /// ``Serializer/Many/Separated``, which inherits `Buffer` and `Element`
    /// from this type and adds a `Separator` parameter.
    public struct Many<Buffer, Element: Serializer.`Protocol`>
    where Element.Buffer == Buffer {
        @usableFromInline
        let element: Element

        @usableFromInline
        let minimum: Int

        /// `Int.max` means no maximum.
        @usableFromInline
        let maximum: Int

        /// Creates a repetition serializer accepting at least the range's lower bound.
        ///
        /// - Parameters:
        ///   - range: The minimum element count; the maximum is unbounded.
        ///   - element: A builder producing the per-element serializer.
        @inlinable
        public init(
            _ range: PartialRangeFrom<Int>,
            @Serializer.Builder<Buffer> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = .max
        }

        /// Creates a repetition serializer whose element count falls within the range.
        ///
        /// - Parameters:
        ///   - range: The inclusive bounds on the element count.
        ///   - element: A builder producing the per-element serializer.
        @inlinable
        public init(
            _ range: ClosedRange<Int>,
            @Serializer.Builder<Buffer> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = range.upperBound
        }

        /// Creates a repetition serializer accepting zero or more elements.
        ///
        /// - Parameter element: A builder producing the per-element serializer.
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
    /// An array of the element serializer's output values.
    public typealias Output = [Element.Output]

    /// A count-bound error or an element-serialization error.
    public typealias Failure = Either<Serializer.Many<Buffer, Element>.Error, Element.Failure>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes each element in order, enforcing the count bounds.
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
