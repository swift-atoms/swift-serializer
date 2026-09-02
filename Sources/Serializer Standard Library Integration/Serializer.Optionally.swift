public import Serializer

extension Serializer::Serializer {

    public struct Optionally<Wrapped: Serializer::Serializer.`Protocol`>: Serializer::Serializer.`Protocol`
    where
        Wrapped.Output: ~Copyable & Escapable,
        Wrapped.Buffer: ~Copyable & ~Escapable
    {
        public typealias Output = Wrapped.Output?

        public typealias Buffer = Wrapped.Buffer

        public typealias Failure = Wrapped.Failure

        @usableFromInline
        internal let wrapped: Wrapped

        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
            switch output {
            case .some(let value):
                try wrapped.serialize(value, into: &buffer)
            case .none:
                return
            }
        }
    }
}
