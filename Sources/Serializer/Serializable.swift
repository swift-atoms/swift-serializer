public protocol Serializable {

    associatedtype Serializer: Serializer::Serializer.`Protocol`
    where
        Serializer.Output: ~Copyable & ~Escapable,
        Serializer.Buffer: ~Copyable & ~Escapable

    static var serializer: Serializer { get }
}
