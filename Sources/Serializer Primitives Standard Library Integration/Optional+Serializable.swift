//
//  Optional+Serializable.swift
//  swift-serializer-primitives
//
//  Serializable conformance for Swift.Optional.
//
//  When the wrapped type is Serializable, Optional<Wrapped> is Serializable.
//  The canonical serializer is Serializer.Optionally<Wrapped.Serializer>:
//  if the value is .none, no bytes are emitted; if .some, delegate to
//  the wrapped serializer.
//
//  Note: @retroactive is not used because the Serializable protocol is
//  declared in the same package as this conformance (Swift's
//  @retroactive is package-scoped, not module-scoped).
//
//  Note: Serializer.Optionally is fully qualified as
//  Serializer_Optional_Primitives.Serializer.Optionally because the
//  unqualified `Serializer` inside this extension resolves to the
//  Serializable.Serializer associatedtype, not the Serializer namespace.

extension Swift.Optional: Serializable where Wrapped: Serializable {
    /// The canonical serializer wraps the element's serializer, emitting nothing for `nil`.
    public static var serializer:
        Serializer_Optional_Primitives.Serializer.Optionally<Wrapped.Serializer>
    {
        Serializer_Optional_Primitives.Serializer.Optionally(Wrapped.serializer)
    }
}
