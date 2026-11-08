#if Map
    public import Serializer_Core
    public import Map
    extension Serializing
    where Self: ~Copyable, Output: ~Copyable & ~Escapable, Buffer: ~Copyable & ~Escapable {

        @inlinable
        public consuming func mapFailure<E: Swift::Error>(
            _ transform: @escaping (Failure) -> E
        ) -> Map<Failure, E, Never>.Error.Serializer<Self> {
            Map<Failure, E, Never>(transform).errorSerializer(self)
        }
    }
#endif

#if Optic
    public import Serializer_Core
    public import Either
    public import Map
    public import Optic

    extension Serializing where Self: ~Copyable, Buffer: ~Copyable & ~Escapable {

        @inlinable
        public consuming func map<Source, Target, Focus, Replacement, ForwardFailure: Swift::Error>(
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
            ForwardFailure: Swift::Error,
            BackwardFailure: Swift::Error
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

#if Optic
    public import Serializer_Core
    public import Map
    public import Optic

    extension Serializing where Self: ~Copyable, Buffer: ~Copyable & ~Escapable {

        @inlinable
        public consuming func map<Source, Target, Focus, Replacement>(
            backward isomorphism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Isomorphism
        ) -> Map<Replacement, Output, Failure>.Serializer<Self>
        where Output == Target {
            contramap { replacement in isomorphism.backward(copy replacement) }
        }
    }

#endif

#if Optic
    public import Serializer_Core
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
        public consuming func map<Source, Target, Focus, Replacement, MatchFailure: Swift::Error>(
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
