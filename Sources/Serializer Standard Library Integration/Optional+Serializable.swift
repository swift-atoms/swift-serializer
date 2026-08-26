extension Swift.Optional: Serializable where Wrapped: Serializable {

    public static var serializer:
        Serializer_Optional.Serializer.Optionally<Wrapped.Serializer>
    {
        Serializer_Optional.Serializer.Optionally(Wrapped.serializer)
    }
}
