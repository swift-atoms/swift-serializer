//
//  Serializable.swift
//  swift-serializer-primitives
//
//  Canonical attachment protocol for serialization.
//

/// A type that has a canonical serializer.
///
/// Conforming types declare their canonical ``Serializer`` and provide a static
/// accessor to obtain it. This enables generic algorithms to discover the
/// serializer for any `Serializable` type.
///
/// ```swift
/// extension IPv4.Address: Serializable {
///     static var serializer: IPv4.Address.Serializer { .init() }
/// }
/// ```
public protocol Serializable {
    /// The canonical serializer type for this value.
    associatedtype Serializer: Serializer_Primitives_Core.Serializer.`Protocol`

    /// The canonical serializer instance.
    static var serializer: Serializer { get }
}

// MARK: - Byte Buffer Convenience

extension Serializable where Serializer.Buffer == [UInt8], Serializer.Output == Self {
    /// The ASCII byte representation of this value using its canonical serializer.
    @inlinable
    public var asciiBytes: [UInt8] {
        var buffer: [UInt8] = []
        try! Self.serializer.serialize(self, into: &buffer)
        return buffer
    }
}

extension Serializable
where Serializer.Buffer == [UInt8], Serializer.Output == Self,
      Serializer.Failure == Never
{
    /// The ASCII byte representation of this value using its canonical serializer.
    ///
    /// Infallible version for serializers that cannot fail.
    @inlinable
    public var asciiBytes: [UInt8] {
        var buffer: [UInt8] = []
        Self.serializer.serialize(self, into: &buffer)
        return buffer
    }
}
