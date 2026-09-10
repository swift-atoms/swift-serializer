#if Repetition
public import Repetition
public import Cardinal
public import Either

extension Repetition where Bounds: Cardinal.Range, Operation: Serializing & ~Copyable,
    Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable {

    public struct Serializer: Serializing, ~Copyable {
        public typealias Output = [Operation.Output]
        public typealias Buffer = Operation.Buffer
        public typealias Failure = Either<Repetition<Bounds, Operation>.Error, Operation.Failure>
        public let wrapped: Repetition<Bounds, Operation>

        public init(_ wrapped: consuming Repetition<Bounds, Operation>) { self.wrapped = wrapped }

        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            guard wrapped.bounds.contains(wrapped.bounds.minimum) else { throw .left(.emptyBounds) }
            let count = Cardinal(UInt(output.count))
            guard wrapped.bounds.contains(count) else {
                throw .left(count < wrapped.bounds.minimum ? .insufficient(actual: count) : .excessive(actual: count))
            }
            for index in output.indices {
                do throws(Operation.Failure) { try wrapped.operation.serialize(output[index], into: &buffer) }
                catch { throw .right(error) }
            }
        }
    }

    public consuming func serializer() -> Serializer { .init(self) }
}

extension Repetition.Serializer: Copyable
where Bounds: Cardinal.Range,
      Operation: Serializing<Operation.Output, Operation.Buffer, Operation.Failure> & Copyable,
      Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable {}
#endif
