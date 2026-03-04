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
