//
//  Serializer.Sequence.swift
//  swift-serializer-primitives
//
//  Sequential composition of serializers consuming a shared output value.
//

extension Serializer {
    /// Namespace for sequential composition serializers.
    ///
    /// ``Serializer/Sequence`` combines multiple serializers that consume the
    /// same `Output` value, writing each in order into the same `Buffer`.
    public enum Sequence {}
}
