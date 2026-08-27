public typealias SerializerProtocol = Serializer.`Protocol`

public protocol Serializable {

    associatedtype Serializer: SerializerProtocol

    static var serializer: Serializer { get }
}
