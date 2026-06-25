//
//  Serializer.Witness.swift
//  swift-serializer-primitives
//
//  Closure-backed serializer witness — one combinator among many.
//

extension Serializer {

    /// A closure-backed serializer — the canonical witness for
    /// ``Serializer/Protocol``.
    ///
    /// `Serializer.Witness` stores a serialize closure and exposes it as
    /// the methods required by ``Serializer/Protocol``. Conformance is
    /// declared in the `Serializer Primitives Core` target so the closure
    /// storage stays in this namespace target.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let asciiInt = Serializer.Witness<Int, [UInt8], Never> { value, buffer in
    ///     buffer.append(contentsOf: "\(value)".utf8)
    /// }
    /// ```
    ///
    /// ## Leaf Witness
    ///
    /// `Serializer.Witness` is a leaf conformer: it implements
    /// ``serialize(_:into:)`` directly via the stored closure rather than
    /// composing through a `body`.
    ///
    /// ## Storage
    ///
    /// `_serialize` is `public` so `@inlinable` methods declared in the
    /// `Serializer Primitives Core` target can inline through. The underscore
    /// signals "implementation hatch — consumers should call
    /// ``serialize(_:into:)`` rather than invoke the closure directly."
    public struct Witness<Output, Buffer, Failure: Swift.Error> {
        /// The stored serialize closure.
        ///
        /// The underscore signals an implementation hatch — call ``serialize(_:into:)`` instead.
        public var _serialize: (Output, inout Buffer) throws(Failure) -> Void

        /// Creates a serializer witness from a serialize closure.
        ///
        /// - Parameter serialize: Serializes an `Output` value by appending to the buffer.
        @inlinable
        public init(_ serialize: @escaping (Output, inout Buffer) throws(Failure) -> Void) {
            self._serialize = serialize
        }
    }

    /// A closure-backed serializer that cannot fail.
    ///
    /// `Serializer.Pure<Output, Buffer>` is shorthand for
    /// `Serializer.Witness<Output, Buffer, Never>`. Use it to elide the
    /// `Failure` type argument when the serializer is infallible.
    ///
    /// ```swift
    /// let s = Serializer.Pure<Int, [UInt8]> { value, buffer in
    ///     buffer.append(contentsOf: String(value).utf8)
    /// }
    /// ```
    public typealias Pure<Output, Buffer> = Witness<Output, Buffer, Never>
}
