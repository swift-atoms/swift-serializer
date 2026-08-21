extension Swift.Optional: Serializable where Wrapped: Serializable {

    public static var serializer:
        Serializer_Optional_Primitives.Serializer.Optionally<Wrapped.Serializer>
    {
        Serializer_Optional_Primitives.Serializer.Optionally(Wrapped.serializer)
    }
}
