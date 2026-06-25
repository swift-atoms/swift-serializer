# Serializer Primitives Scope

The identity surface of `swift-serializer-primitives`, and what is deliberately out of it.

## Identity

`swift-serializer-primitives` provides the **one-way, machine-readable serialization
substrate** — the policy-free `Serializer` namespace, its canonical `Serializer.Protocol`
(O(1) amortized append into a buffer), the closure-backed `Serializer.Witness` leaf, the
`Serializer.Builder` result builder, the `Serializable` attachment protocol, and the
combinators that compose serializers declaratively (map, filter, optional, many, sequence,
literal, always, fail, lazy, trace). It is serialize-only: a value contains all information
needed to serialize, so the surface is context-free. Parsing, deserialization, encoding to
bytes, and human-readable printing/formatting are NOT part of this package's identity.

## Per-[MOD-031] shape

Per [MOD-017]/[MOD-031], the root namespace + foundational declarations live in the singular
`Serializer Primitive`, and each external-dependency-bearing sub-namespace is its own target:

- **Serializer Primitive** — the `public enum Serializer {}` namespace root and its foundational,
  stdlib-only declarations: `Serializer.Protocol`, `Serializer.Builder`, `Serializer.Witness`
  (+ `Serializer.Pure`), the `Serializer.Witness: Serializer.Protocol` conformance, and the
  `Serializable` attachment protocol. Zero external dependencies per [MOD-017].
- **Serializer Tagged Primitives** — `Tagged.Serializable` integration (`Tagged_Primitives`
  external dep); lifts an underlying value's canonical serializer to operate on `Tagged` values.
- **Serializer Map Primitives** — `Serializer.Map` output-mapping combinator (`Either_Primitives`).
- **Serializer Filter Primitives** — `Serializer.Filter` predicate combinator (`Either_Primitives`).
- **Serializer Optional Primitives** — `Serializer.Optionally`, runtime-optional no-op-on-nil.
- **Serializer Many Primitives** — `Serializer.Many` repetition combinator (`Either_Primitives`).
- **Serializer Sequence Primitives** — `Serializer.Sequence` + `Serializer.Builder` sequential
  composition (`Either_Primitives`).
- **Serializer Literal Primitives** — `Serializer.Literal` fixed-byte combinator (`Byte_Primitives`).
- **Serializer Always Primitives** — `Serializer.Always`, the always-succeeding serializer.
- **Serializer Fail Primitives** — `Serializer.Fail`, the always-failing serializer.
- **Serializer Lazy Primitives** — `Serializer.Lazy`, deferred-construction combinator.
- **Serializer Trace Primitives** — `Serializer.Trace`, diagnostic pass-through.
- **Serializer Primitives Standard Library Integration** — `Swift.Optional: Serializable`
  conformance via `Serializer.Optionally`.
- **Serializer Primitives** — umbrella; re-exports the root + every sub-namespace above so a
  consumer needing the union writes `import Serializer_Primitives`.
- **Serializer Primitives Core** — DEPRECATED transitional shim (L1 core-dissolution sweep
  2026-06-23); exports-only, re-exports the dissolved Core surface (root + Tagged). Removed in
  the cleanup wave.

## Out of scope

These compose with the package but lie OUTSIDE its identity surface:

- **Parsing / deserialization** (raw input → structure → typed value): → the parser family
  (`swift-parser-primitives` and siblings). Serialization is one-way; the inverse is not owned here.
- **Encoding/decoding to bytes** (intermediate → `[UInt8]`): a downstream encode step, distinct
  from serialization (value → interchange representation).
- **Human-readable printing / formatting** (`CustomStringConvertible`, format styles): out of
  scope; serialization is round-trippable machine interchange, not presentation.
- **Domain-specific serializer flavors** (ASCII, byte, JSON): → their own sibling/foundation
  packages (e.g. `swift-ascii-serializer-primitives`), which build ON this substrate.

## Evaluation rule

Sub-target additions are evaluated against this scope. A proposed addition that is a
**buffer-appending serialize combinator or attachment protocol** lands as / within a sub-namespace
target per [MOD-031]; anything that parses, decodes bytes, prints for humans, or pins a concrete
output domain extracts to a sibling package, not into this one.
