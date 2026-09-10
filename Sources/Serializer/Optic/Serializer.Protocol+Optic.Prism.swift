#if Optic
public import Either
public import Map
public import Optic

extension Serializing where Self: ~Copyable, Buffer: ~Copyable & ~Escapable {

    @inlinable
    public consuming func map<Source, Target, Focus, Replacement>(
        embedding prism: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Prism
    ) -> Map<Replacement, Output, Failure>.Serializer<Self>
    where Output == Target {
        contramap { replacement in prism.embed(copy replacement) }
    }

    @inlinable
    public consuming func map<Source, Target, Focus, Replacement>(
        matching prism: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Prism
    ) -> Map<Source, Output, Failure>.Serializer<Self>
    where Output == Either<Target, Focus> {
        contramap { source in prism.match(copy source) }
    }

    @_disfavoredOverload
    @inlinable
    public consuming func map<Source, Target, Focus, Replacement, MatchFailure: Swift.Error>(
        matching prism: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Prism,
        failure transform: @escaping (consuming Target) -> MatchFailure
    ) -> Map<Source, Output, Either<Failure, MatchFailure>>.Serializer<Self>
    where Output == Focus {
        contramap { source throws(MatchFailure) in
            switch prism.match(copy source) {
            case .left(let target):
                throw transform(target)
            case .right(let focus):
                return focus
            }
        }
    }
}

#endif
