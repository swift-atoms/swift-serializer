#if Lazy
public import Lazy
public import Either

extension Lazy::Lazy
where
    Value: Serializing & ~Copyable,
    Value.Buffer: ~Copyable & ~Escapable,
    Value.Output: ~Copyable & ~Escapable
{

    public struct Serializer<Failure: Swift.Error>: Serializing {
        public typealias Buffer = Value.Buffer
        public typealias Output = Value.Output

        public let wrapped: Lazy::Lazy<Value, FactoryFailure>
        @usableFromInline internal let factoryFailure: (FactoryFailure) -> Failure
        @usableFromInline internal let serializeFailure: (Value.Failure) -> Failure

        @inlinable
        public init(_ wrapped: Lazy::Lazy<Value, FactoryFailure>)
        where FactoryFailure == Never, Failure == Value.Failure {
            self.wrapped = wrapped
            self.factoryFailure = { $0 }
            self.serializeFailure = { $0 }
        }

        @inlinable
        public init(_ wrapped: Lazy::Lazy<Value, FactoryFailure>)
        where Failure == Either<FactoryFailure, Value.Failure> {
            self.wrapped = wrapped
            self.factoryFailure = { .left($0) }
            self.serializeFailure = { .right($0) }
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            let parser: Value
            do throws(FactoryFailure) {
                parser = try wrapped()
            } catch {
                throw factoryFailure(error)
            }
            do throws(Value.Failure) {
                try parser.serialize(output, into: &buffer)
            } catch {
                throw serializeFailure(error)
            }
        }
    }

    @inlinable
    public func serializer() -> Serializer<Either<FactoryFailure, Value.Failure>> {
        .init(self)
    }

    @inlinable
    public func serializer() -> Serializer<Value.Failure> where FactoryFailure == Never {
        .init(self)
    }
}
#endif
