public import Serializer

extension Swift.Optional: Serializable where Wrapped: Serializable {

    @inlinable
    public static var serializer: Serializer::Serializer.Optionally<Wrapped.Serializer> {
        Serializer::Serializer.Optionally(Wrapped.serializer)
    }
}
