public import Serializer

extension Swift.Optional: Serializable where Wrapped: Serializable {

    public static var serializer:
        Serializer.Serializer.Optionally<Wrapped.Serializer>
    {
        Serializer.Serializer.Optionally(Wrapped.serializer)
    }
}
