public import Serializer

extension Swift.Optional: Serializable
where
    Wrapped: Serializable,
    Wrapped.Serializer.Output: ~Copyable & Escapable,
    Wrapped.Serializer.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public static var serializer: Serializer::Serializer.Optionally<Wrapped.Serializer> {
        Serializer::Serializer.Optionally(Wrapped.serializer)
    }
}
