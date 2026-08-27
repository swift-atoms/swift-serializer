public import Serializer

extension Swift.Optional: Serializable where Wrapped: Serializable {

    public static var serializer:
        Serializer.Optionally<Wrapped.Serializer>
    {
        .init(Wrapped.serializer)
    }
}
