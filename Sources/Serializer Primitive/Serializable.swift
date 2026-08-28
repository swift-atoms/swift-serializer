public protocol Serializable {

    associatedtype Serializer: Serializer_Primitive.Serializer.`Protocol`

    static var serializer: Serializer { get }
}
