#if Either
public import Either

extension Either
where
    Left: Serializing & ~Copyable,
    Right: Serializing & ~Copyable,
    Left.Buffer == Right.Buffer,
    Left.Output == Right.Output,
    Left.Buffer: ~Copyable & ~Escapable,
    Right.Buffer: ~Copyable & ~Escapable,
    Left.Output: ~Copyable & ~Escapable,
    Right.Output: ~Copyable & ~Escapable
{
    public struct Serializer: Serializing, ~Copyable {
        public typealias Buffer = Left.Buffer
        public typealias Output = Left.Output
        public typealias Failure = Either<Left.Failure, Right.Failure>

        public let wrapped: Either<Left, Right>

        @inlinable
        public init(_ wrapped: consuming Either<Left, Right>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            switch wrapped {
            case .left(let parser):
                do throws(Left.Failure) {
                    try parser.serialize(output, into: &buffer)
                } catch {
                    throw .left(error)
                }
            case .right(let parser):
                do throws(Right.Failure) {
                    try parser.serialize(output, into: &buffer)
                } catch {
                    throw .right(error)
                }
            }
        }
    }

    @inlinable
    public consuming func serializer() -> Serializer {
        .init(self)
    }
}
extension Either.Serializer: Copyable
where Left: Serializing<Left.Output, Left.Buffer, Left.Failure> & Copyable,
      Right: Serializing<Right.Output, Right.Buffer, Right.Failure> & Copyable,
      Left.Buffer: ~Copyable & ~Escapable, Right.Buffer: ~Copyable & ~Escapable,
      Left.Output: ~Copyable & ~Escapable, Right.Output: ~Copyable & ~Escapable {}
#endif
