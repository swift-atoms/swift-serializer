public protocol Serializable {

    associatedtype Serializer: Serializing
    where
        Serializer.Output: ~Copyable & ~Escapable,
        Serializer.Buffer: ~Copyable & ~Escapable

    static var serializer: Serializer { get }
}
