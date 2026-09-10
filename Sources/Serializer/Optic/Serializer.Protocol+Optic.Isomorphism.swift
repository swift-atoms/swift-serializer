#if Optic
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
