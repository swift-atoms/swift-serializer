#if Pair
public import Either
public import Pair

extension Pair::Pair
where
    First: Serializing & ~Copyable,
    Second: Serializing & ~Copyable,
    First.Buffer == Second.Buffer,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable,
    First.Buffer: ~Copyable & ~Escapable,
    Second.Buffer: ~Copyable & ~Escapable
{

    @frozen
    public struct Serializer<Failure: Swift.Error>: Serializing, ~Copyable {

        public typealias Output = Pair::Pair<First.Output, Second.Output>

        public typealias Buffer = First.Buffer

        @usableFromInline
        internal let first: First

        @usableFromInline
        internal let second: Second

        @usableFromInline
        internal let firstFailure: (First.Failure) -> Failure

        @usableFromInline
        internal let secondFailure: (Second.Failure) -> Failure

        @inlinable
        public init(
            upstream: consuming Pair::Pair<First, Second>,
            failure: consuming Pair::Pair<
                (First.Failure) -> Failure,
                (Second.Failure) -> Failure
            >
        ) {
            self.first = upstream.first
            self.second = upstream.second
            self.firstFailure = failure.first
            self.secondFailure = failure.second
        }

        @inlinable
        public borrowing func serialize(
            _ output: borrowing Output,
            into buffer: inout Buffer
        ) throws(Failure) {
            do throws(First.Failure) {
                try first.serialize(output.first, into: &buffer)
            } catch {
                throw firstFailure(error)
            }
            do throws(Second.Failure) {
                try second.serialize(output.second, into: &buffer)
            } catch {
                throw secondFailure(error)
            }
        }
    }

    @_disfavoredOverload
    @inlinable
    public consuming func serializer() -> Pair::Pair<First, Second>.Serializer<Either<First.Failure, Second.Failure>> {
        .init(
            upstream: self,
            failure: Pair::Pair<
                (First.Failure) -> Either<First.Failure, Second.Failure>,
                (Second.Failure) -> Either<First.Failure, Second.Failure>
            >({ .left($0) }, { .right($0) })
        )
    }

    @inlinable
    public consuming func serializer() -> Pair::Pair<First, Second>.Serializer<First.Failure>
    where First.Failure == Second.Failure {
        .init(
            upstream: self,
            failure: Pair::Pair<(First.Failure) -> First.Failure, (Second.Failure) -> First.Failure>({ $0 }, { $0 })
        )
    }
}

extension Pair.Serializer: Copyable
where First: Serializing<First.Output, First.Buffer, First.Failure> & Copyable,
      Second: Serializing<Second.Output, Second.Buffer, Second.Failure> & Copyable,
      First.Output: ~Copyable & Escapable, Second.Output: ~Copyable & Escapable,
      First.Buffer: ~Copyable & ~Escapable, Second.Buffer: ~Copyable & ~Escapable {}

#endif
