//
//  Serializer.Sequence.swift
//  swift-serializer-primitives
//
//  Sequential composition of serializers consuming a shared output value.
//

extension Serializer {
    /// Namespace for sequential composition serializers.
    ///
    /// ``Serializer/Sequence`` combines multiple serializers that consume the
    /// same `Output` value, writing each in order into the same `Buffer`.
    public enum Sequence {}
}

// MARK: - Two

extension Serializer.Sequence {
    /// A serializer that applies two serializers sequentially, writing each
    /// into the same buffer with the same input value.
    public struct Two<P0: Serializer.`Protocol`, P1: Serializer.`Protocol`>
    where
        P0.Output == P1.Output,
        P0.Buffer == P1.Buffer
    {
        @usableFromInline
        internal let p0: P0

        @usableFromInline
        internal let p1: P1

        /// Creates a serializer that applies `p0` then `p1` to the same value.
        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Serializer.Sequence.Two: Serializer.`Protocol` {
    /// The shared output type of both serializers.
    public typealias Output = P0.Output

    /// The shared buffer type of both serializers.
    public typealias Buffer = P0.Buffer

    /// A failure from the first or the second serializer.
    public typealias Failure = Either<P0.Failure, P1.Failure>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes the value through both serializers in order.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}

// MARK: - Three

extension Serializer.Sequence {
    /// A serializer that applies three serializers sequentially, writing each
    /// into the same buffer with the same input value.
    public struct Three<
        P0: Serializer.`Protocol`,
        P1: Serializer.`Protocol`,
        P2: Serializer.`Protocol`
    >
    where
        P0.Output == P1.Output,
        P1.Output == P2.Output,
        P0.Buffer == P1.Buffer,
        P1.Buffer == P2.Buffer
    {
        @usableFromInline
        internal let p0: P0

        @usableFromInline
        internal let p1: P1

        @usableFromInline
        internal let p2: P2

        /// Creates a serializer that applies `p0`, then `p1`, then `p2` to the same value.
        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }
    }
}

extension Serializer.Sequence.Three: Serializer.`Protocol` {
    /// The shared output type of all three serializers.
    public typealias Output = P0.Output

    /// The shared buffer type of all three serializers.
    public typealias Buffer = P0.Buffer

    /// A failure from the first, second, or third serializer.
    public typealias Failure = Either<P0.Failure, Either<P1.Failure, P2.Failure>>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Serializes the value through all three serializers in order.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output, into: &buffer)
        } catch {
            throw .right(.left(error))
        }
        do throws(P2.Failure) {
            try p2.serialize(output, into: &buffer)
        } catch {
            throw .right(.right(error))
        }
    }
}
