# Serializer

`Serializing<Output, Buffer, Failure>` serializes a **borrowed** value into an independently represented mutable buffer. `Serializer<Output, Buffer, Failure>` is the direct typed function representation.

```swift
import Serializer

let decimal = Serializer<Int, String, Never> { value, buffer in
    buffer += String(value)
}
var buffer = ""
decimal.serialize(42, into: &buffer) // "42"
```

Named serializers can implement `serialize(_:into:)` or delegate through an opaque body that preserves all three associated types, including `Never`:

```swift
struct Decimal: Serializing {
    var body: some Serializing<Int, String, Never> {
        Serializer<Int, String, Never> { value, buffer in
            buffer += String(value)
        }
    }
}
```

`Serializer { ... }` builds its composition once. With the `Pair` trait, successive expressions serialize structural `Pair` fields in order, without tuple-layout recovery. Nested composition uses nested pairs. Neither sequencing nor failure mapping rolls the buffer back after an error; an earlier successful write remains visible.

```swift
let coordinates = Serializer { Decimal(); Decimal() }
var text = ""
coordinates.serialize(Pair(12, 34), into: &text) // "1234"
```

That last example only demonstrates serialization. A wire grammar needs delimiters, lengths, or other framing before adjacent decimal values can round-trip. Serializing conformance by itself makes no parsing or inverse-law guarantee.

The `Map` trait provides borrowed `contramap` and structural `mapFailure`. A total contramap preserves the upstream failure. A throwing transform uses `Either<Upstream.Failure, TransformFailure>`, or just `TransformFailure` when the upstream is infallible. `Map<Source, Target, Failure>.Serializer` stores a borrowed projection closure: it does not consume the source through the general `Map` arrow.

The `Optic` trait adds backward adapter/isomorphism and prism embedding/matching conveniences. Those conveniences explicitly require copyable optic source types because the optic arrows consume their input. They do not justify copying a borrowed noncopyable domain value. Use a concrete borrowed `serialize` implementation for that case. Adapter normalization is not a claim of exact inversion.

`Optional<ElementSerializer>.Serializer` prints an optional **value**: `.none` emits nothing; `.some` must serialize successfully or throw. Builder `if/else` instead selects a serializer at construction time and retains branch failure provenance through `Either`. It is not a retrying alternative.

`Lazy<Serializer, FactoryFailure>.Serializer` builds a fresh serializer per call. It distinguishes factory failure from serialization failure, and an infallible factory preserves the serializer's exact failure. Results are not cached; a failed factory can be retried. `Tagged<Tag, Value>.Serializer(upstream)` stores an explicitly selected upstream serializer and delegates through borrowed access to the underlying value. Both the value and upstream serializer may be noncopyable.

`Always<Value>.Serializer` deliberately discards every supplied value and emits nothing; its stored base value is not an equality check. It is a one-way serializer and does not promise a coder's value round-trip.

The `Collection` trait adds `serialize(value) -> Buffer` for a fresh `RangeReplaceableCollection` buffer. The `Repetition` trait provides `Repetition(bounds, operation: element).serializer()` and `.serializer(separator: separator)` using `Cardinal.Range` bounds. They validate the full array count before writing anything, sharing `.emptyBounds`, `.insufficient(actual:)`, and `.excessive(actual:)` with the repetition algebra. Separators have `Void` output and appear only between elements. Element/separator failures propagate with their partial writes; they never silently shorten the array. Array elements currently must be copyable and escapable, while both serializer components and buffers may be noncopyable.

```swift
let list = Repetition(Cardinal(1)...Cardinal(3), operation: Decimal())
    .serializer(separator: [Character].Serializer<String>([","]))
var text = ""
try list.serialize([12, 34], into: &text) // "12,34"
```

Select the representation explicitly: construct a serializer and pass the value to `serialize(_:into:)`. A domain value can have multiple wire formats without choosing a global static serializer. `Optional<OwnedSerializer>.Serializer(owned)` stores a noncopyable component directly.

Direct serializers, bodies, contramaps, and structural error maps support borrowed noncopyable and scoped values, including `Span`. Buffers may be noncopyable. Structural pairs support noncopyable fields and serializer components; their fields must currently be escapable. The direct function wrapper is copyable, so copies share its captured closure resources; structural combinators preserve a noncopyable upstream's ownership.

## Dependencies and migration

The `Serializer` product owns the `Either`, `Map`, `Pair`, `Optic`, `Always`, `Lazy`, `Tagged`, `Collection`, and `Repetition` integrations as independently selectable traits. All are enabled by default. `Map` and `Pair` enable `Either`; `Optic` enables `Map`; `Lazy` and `Repetition` enable `Either`. Disable defaults for core-only use. No runtime macro dependency is introduced.

- `Serializer.Protocol` → `Serializing`.
- `Serializer.Witness<O, B, E>` → `Serializer<O, B, E>`.
- `Serializer.Pure<O, B>` → `Serializer<O, B, Never>`.
- `Serializer.Map<S, O>` → inferred `.contramap(...)`, represented by `Map<O, S.Output, E>.Serializer<S>`.
- `.error.map(...)` / `Serializer.Error.Transform(...)` → consuming `.mapFailure(...)`.
- `Serializer.Optionally<S>` → `Optional<S>.Serializer`.
- Bare `Either` and `Lazy` serialization → `.serializer().serialize(...)`, or use the algebra value directly inside `Serializer { ... }`.
- `Serializable` and its static `serializer` selector are removed. Pass an explicit serializer, including for optional and tagged values.
- `Tagged.UnderlyingSerializer` → `Tagged.Serializer(upstream)`.
- `Serializer.Many<Buffer, Element>(range, element: ...)` → `Repetition(cardinalRange, operation: ...).serializer()`; `.Many.Separated` → `.serializer(separator: ...)`. Use nonnegative Cardinal bounds instead of Int bounds. Count errors are the shared repetition errors above.
- `Collection Serializer Buffer` / `Collection Serializer Many` products → the `Serializer` product with `Collection` / `Repetition` traits; the old products re-export it.
- `import Pair_Serializer`, `Optic_Serializer`, `Either_Serializer`, `Lazy_Serializer`, `Always_Serializer`, or `Tagged_Serializer` → `import Serializer` with the relevant trait. The old integration products remain compatibility re-exports without duplicate implementations.

`Map.Error` now belongs to the general Map algebra, so both Parser and Serializer extend one shared namespace. Existing `Map.Error.Parser` spelling remains unchanged.


The existing format-specific `ASCII.Serializable` and `Binary.Serializable` streaming contracts remain in their representation packages. They directly write a fixed format and do not select a global generic serializer.
