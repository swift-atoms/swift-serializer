#if Optic
public import Either
public import Map
public import Optic

extension Serializing where Self: ~Copyable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public consuming func map<Source, Target, Focus, Replacement, ForwardFailure: Swift.Error>(
        backward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<ForwardFailure, Never>
    ) -> Map<Replacement, Output, Failure>.Serializer<Self>
    where Output == Target {
        contramap { replacement in adapter.backward(copy replacement) }
    }

    @_disfavoredOverload
    @inlinable
    public consuming func map<
        Source,
        Target,
        Focus,
        Replacement,
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >(
        backward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<ForwardFailure, BackwardFailure>
    ) -> Map<Replacement, Output, Either<Failure, BackwardFailure>>.Serializer<Self>
    where Output == Target {
        contramap { replacement throws(BackwardFailure) in
            try adapter.backward(copy replacement)
        }
    }
}

#endif
