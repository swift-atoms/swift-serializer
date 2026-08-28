public enum __SerializerFilterError: Swift.Error {

    case validationFailed(value: String, reason: String)
}

extension Serializer.Filter {

    public typealias Error = __SerializerFilterError
}
