// Tagged+Serializable.swift
// swift-serializer-primitives
//
// Canonical generic Serializable conformance for Tagged. Tagged<Tag, Underlying>
// is Serializable when Underlying is — its serialization delegates to the
// underlying value's canonical serializer. The wrapper Serializer type
// (`Tagged<Tag, Underlying>.UnderlyingSerializer`) lifts the underlying's
// Serializer surface to operate on Tagged values while preserving the
// underlying's Buffer and Failure shapes.
//
// This is domain-agnostic: Tagged becomes Serializable for ANY Underlying that
// is Serializable — binary-domain (`Underlying.Serializer == Binary.Serializer<Underlying>`)
// JSON-domain, ASCII-domain, future serializer flavors all work uniformly.

public import Serializer_Primitive
public import Tagged_Primitives

extension Tagged where Underlying: Serializable, Underlying.Serializer.Output == Underlying {
    /// Wrapper serializer that lifts `Underlying.Serializer` to operate on
    /// `Tagged<Tag, Underlying>` values.
    ///
    /// `serialize(_:into:)` extracts the underlying value and delegates to
    /// `Underlying.serializer.serialize(_:into:)`. The Buffer and Failure
    /// types are inherited from the underlying's serializer — Tagged adds
    /// no error or buffer-shape concerns of its own.
    public struct UnderlyingSerializer: Serializer_Primitive.Serializer.`Protocol` {
        /// Creates the lifting serializer.
        @inlinable
        public init() {}
    }
}

// swift-linter:disable:next extension noncopyable constraint
// REASON: `Tag` is already pinned to `Copyable` by the enclosing declaration
// (`extension Tagged where Underlying: Serializable, ...` at this file's top,
// which lacks `Tag: ~Copyable` and is what introduces `UnderlyingSerializer`
// in the first place) — adding `Tag: ~Copyable` here does not widen the
// surface, it fails to compile (`'Tag' required to be 'Copyable' but is
// marked with '~Copyable'`), confirmed by a full package build.
extension Tagged.UnderlyingSerializer where Underlying: Serializable, Underlying.Serializer.Output == Underlying {
    /// The wrapped `Tagged` value this serializer accepts.
    public typealias Output = Tagged<Tag, Underlying>

    /// The buffer type is inherited from the underlying value's serializer.
    public typealias Buffer = Underlying.Serializer.Buffer

    /// The failure type is inherited from the underlying value's serializer.
    public typealias Failure = Underlying.Serializer.Failure

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Extracts the underlying value and delegates to its canonical serializer.
    @inlinable
    public borrowing func serialize(
        _ output: Tagged<Tag, Underlying>,
        into buffer: inout Underlying.Serializer.Buffer
    ) throws(Underlying.Serializer.Failure) {
        try Underlying.serializer.serialize(output.underlying, into: &buffer)
    }
}

extension Tagged: Serializable
where
    Underlying: Serializable,
    Underlying.Serializer.Output == Underlying
{
    /// The canonical serializer that lifts the underlying value's serializer to `Tagged`.
    @inlinable
    public static var serializer: Tagged<Tag, Underlying>.UnderlyingSerializer {
        Tagged<Tag, Underlying>.UnderlyingSerializer()
    }
}
