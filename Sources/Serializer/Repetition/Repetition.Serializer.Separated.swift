#if Repetition
public import Repetition
public import Cardinal
public import Either

extension Repetition.Serializer where Bounds: Cardinal.Range,
    Operation: Serializing & ~Copyable, Operation.Output: Copyable & Escapable,
    Operation.Buffer: ~Copyable & ~Escapable {

    public struct Separated<Separator: Serializing & ~Copyable>: Serializing, ~Copyable
    where Separator.Output == Void, Separator.Buffer == Operation.Buffer,
          Separator.Buffer: ~Copyable & ~Escapable {
        public typealias Output = [Operation.Output]
        public typealias Buffer = Operation.Buffer
        public typealias Failure = Either<Repetition<Bounds, Operation>.Error, Either<Operation.Failure, Separator.Failure>>
        public let wrapped: Repetition<Bounds, Operation>
        public let separator: Separator

        public init(_ wrapped: consuming Repetition<Bounds, Operation>, separator: consuming Separator) {
            self.wrapped = wrapped
            self.separator = separator
        }

        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            guard wrapped.bounds.contains(wrapped.bounds.minimum) else { throw .left(.emptyBounds) }
            let count = Cardinal(UInt(output.count))
            guard wrapped.bounds.contains(count) else {
                throw .left(count < wrapped.bounds.minimum ? .insufficient(actual: count) : .excessive(actual: count))
            }
            for index in output.indices {
                if index > 0 {
                    do throws(Separator.Failure) { try separator.serialize((), into: &buffer) }
                    catch { throw .right(.right(error)) }
                }
                do throws(Operation.Failure) { try wrapped.operation.serialize(output[index], into: &buffer) }
                catch { throw .right(.left(error)) }
            }
        }
    }
}

extension Repetition where Bounds: Cardinal.Range, Operation: Serializing & ~Copyable,
    Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable {
    public consuming func serializer<S: Serializing & ~Copyable>(separator: consuming S) -> Serializer.Separated<S>
    where S.Output == Void, S.Buffer == Operation.Buffer, S.Buffer: ~Copyable & ~Escapable {
        .init(self, separator: separator)
    }
}

extension Repetition.Serializer.Separated: Copyable
where Bounds: Cardinal.Range,
      Operation: Serializing<Operation.Output, Operation.Buffer, Operation.Failure> & Copyable,
      Operation.Output: Copyable & Escapable, Operation.Buffer: ~Copyable & ~Escapable,
      Separator: Serializing<Void, Operation.Buffer, Separator.Failure> & Copyable,
      Separator.Buffer: ~Copyable & ~Escapable {}
#endif
