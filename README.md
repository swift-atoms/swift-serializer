# Serializer Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Declarative, one-way serialization for Swift — a `Serializer.Protocol` family that appends a value's representation to a buffer, with composable combinators (`map`, `filter`, `sequence`, `repetition`, `literal`) and a result-builder DSL, all with typed throws and zero platform dependencies.

---

## Quick Start

A serializer appends a value's machine-readable representation to a buffer. The leaf conformer is `Serializer.Witness`, a closure-backed serializer; combinators compose serializers into larger ones, and a `@Serializer.Builder` `var body` lets a domain type declare its format declaratively.

```swift
import Serializer

// A leaf serializer: write an unsigned byte, infallibly.
let octet = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
    buffer.append(value)
}

// Failure == Never means no `try` at the call site; returns a fresh buffer.
let bytes: [UInt8] = octet.serialize(255)   // [255]

// Compose declaratively: a dotted-quad serializer built from a `var body`.
struct DottedQuad: Serializer.`Protocol` {
    typealias Output = (UInt8, UInt8, UInt8, UInt8)
    typealias Buffer = [UInt8]
    typealias Failure = Never

    var body: some Serializer.`Protocol`<Output, [UInt8], Never> {
        Serializer.Witness<Output, [UInt8], Never> { quad, buffer in
            buffer.append(contentsOf: "\(quad.0).\(quad.1).\(quad.2).\(quad.3)".utf8)
        }
    }
}

let address: [UInt8] = DottedQuad().serialize((192, 168, 0, 1))   // "192.168.0.1" as UTF-8
```

Transform inputs with `map`, validate with `filter`, and recover the failure type through the typed-throws channel:

```swift
import Serializer
import Serializer_Map

let octet = Serializer.Witness<UInt8, [UInt8], Never> { value, buffer in
    buffer.append(value)
}

// Contravariantly map a String to the byte serializer's UInt8 input.
let lengthByte = octet.map { (text: String) -> UInt8 in UInt8(text.utf8.count) }
let encoded: [UInt8] = lengthByte.serialize("hello")   // [5]
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Serializer", package: "swift-serializer"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

The namespace target carries the protocol and the closure-backed witness; each combinator is its own target so consumers depend only on what they use. The umbrella re-exports everything.

| Product | When to import |
|---------|----------------|
| `Serializer Primitive` | The `Serializer.Protocol`, `Serializer.Witness` / `Serializer.Pure`, `Serializable`, and `Serializer.Builder`. The minimal core. |
| `Serializer Map Primitives` | Contravariant input transforms — `map(_:)` and throwing `tryMap(_:)`. |
| `Serializer Filter Primitives` | Predicate validation — `filter(_:)`. |
| `Serializer Sequence Primitives` | Sequential composition (`Sequence.Two` / `Sequence.Three`) over one shared value. |
| `Serializer Many Primitives` | Repetition with count bounds, and separator-delimited repetition. |
| `Serializer Optional Primitives` | Compile-time-optional (`Optional`) and runtime-optional (`Optionally`) serializers. |
| `Serializer Literal Primitives` | Fixed byte-sequence emission for delimiters and keywords. |
| `Serializer Always Primitives` | The identity serializer that writes nothing. |
| `Serializer Fail Primitives` | The serializer that always throws a chosen error. |
| `Serializer Lazy Primitives` | Deferred construction for recursive formats. |
| `Serializer Trace Primitives` | Debug tracing around any serializer. |
| `Serializer Tagged Primitives` | `Serializable` for `Tagged`, lifting the underlying value's serializer. |
| `Serializer Standard Library Integration` | `Serializable` for `Swift.Optional`. |
| `Serializer Primitives` | Umbrella re-exporting every product above. |

Foundation-free; depends only on other primitives packages.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
