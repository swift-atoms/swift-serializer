//
//  Serializer.Map.Throwing.swift
//  swift-serializer-primitives
//
//  Throwing contravariant output transformation.
//

public import Either_Primitives

extension Serializer.Map {
    /// A serializer that transforms its input value using a throwing function before
    /// delegating to another serializer.
    ///
    /// If the transformation throws, serialization fails with that error.
    /// The resulting failure type is `Either<Upstream.Failure, E>`.
    ///
    /// Created via `serializer.tryMap(_:)`.
    ///
    /// ## Shared generics
    ///
    /// `Upstream` and `NewOutput` are inherited from the outer ``Serializer/Map``
    /// type; only the error parameter `E` is added at this nesting level.
    public struct Throwing<E: Swift.Error> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (NewOutput) throws(E) -> Upstream.Output

        /// Creates a throwing mapping serializer.
        ///
        /// - Parameters:
        ///   - upstream: The serializer to delegate to after transforming the input.
        ///   - transform: A throwing function from the new input to the upstream output.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (NewOutput) throws(E) -> Upstream.Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Serializer.Map.Throwing: Serializer.`Protocol` {
    /// The buffer type is inherited from the upstream serializer.
    public typealias Buffer = Upstream.Buffer

    /// An upstream failure or a transform error.
    public typealias Failure = Either<Upstream.Failure, E>

    /// A leaf serializer has no composed body.
    public typealias Body = Never

    /// Transforms the input (which may throw), then serializes it via the upstream serializer.
    @inlinable
    public func serialize(_ output: NewOutput, into buffer: inout Buffer) throws(Failure) {
        let upstreamInput: Upstream.Output
        do throws(E) {
            upstreamInput = try transform(output)
        } catch {
            throw .right(error)
        }
        do throws(Upstream.Failure) {
            try upstream.serialize(upstreamInput, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
