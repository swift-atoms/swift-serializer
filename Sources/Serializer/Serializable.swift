public protocol Serializable {

    associatedtype Serializer: Serializer.Serializer.`Protocol`

    static var serializer: Serializer { get }
}
