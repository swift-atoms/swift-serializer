//
//  Serializer.Many.Error.swift
//  swift-serializer-primitives
//
//  Errors from repetition serializers.
//

extension Serializer.Many {
    /// Errors from repetition serializers.
    ///
    /// Only count constraint violations produce errors directly. Element and
    /// separator serialization failures are surfaced separately via the
    /// compound `Failure` of `Many.Simple` / `Many.Separated`.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Element count below minimum requirement.
        ///
        /// - Parameters:
        ///   - expected: The minimum required count
        ///   - got: The actual count provided
        case countTooLow(expected: Int, got: Int)

        /// Element count above maximum limit.
        ///
        /// - Parameters:
        ///   - expected: The maximum allowed count
        ///   - got: The actual count provided
        case countTooHigh(expected: Int, got: Int)
    }
}
