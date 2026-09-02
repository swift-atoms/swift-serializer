extension Serializer.Filter {

    public enum Error: Swift.Error, Equatable {

        case validationFailed(value: String, reason: String)
    }
}
