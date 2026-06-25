//
//  Serializer.Builder.swift
//  swift-serializer-primitives
//
//  Result builder for declarative serializer composition.
//

extension Serializer {
    /// A result builder for composing serializers.
    ///
    /// ``Serializer/Builder`` enables declarative serializer composition using
    /// Swift's result builder syntax. It is the canonical builder for
    /// ``Serializer/Protocol/body-swift.property``.
    ///
    /// The generic parameter `B` is the buffer type (named `B` to avoid
    /// shadowing the outer ``Serializer/Protocol``'s `Buffer` associated type
    /// at builder use-sites).
    ///
    /// Sequential composition, combinators, and conditionals are added via
    /// extensions in downstream modules.
    @resultBuilder
    public struct Builder<B> {}
}

// MARK: - Single Expression (Pass-Through)

extension Serializer.Builder {
    /// Wraps an expression in the builder context.
    @inlinable
    public static func buildExpression<S: Serializer.`Protocol`>(
        _ serializer: S
    ) -> S where S.Buffer == B {
        serializer
    }

    /// Builds a single serializer unchanged.
    @inlinable
    public static func buildBlock<S: Serializer.`Protocol`>(
        _ serializer: S
    ) -> S where S.Buffer == B {
        serializer
    }

    /// Starts building a partial block.
    @inlinable
    public static func buildPartialBlock<S: Serializer.`Protocol`>(
        first: S
    ) -> S where S.Buffer == B {
        first
    }
}
