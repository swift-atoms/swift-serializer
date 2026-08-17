// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-serializer-primitives",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27")
    ],
    products: [
        // MARK: - Namespace
        .library(
            name: "Serializer Primitive",
            targets: ["Serializer Primitive"]
        ),
        // MARK: - Tagged Integration
        .library(
            name: "Serializer Tagged Primitives",
            targets: ["Serializer Tagged Primitives"]
        ),
        // MARK: - Witness (closure-backed leaf conformer)
        .library(
            name: "Serializer Witness Primitives",
            targets: ["Serializer Witness Primitives"]
        ),
        // MARK: - Core (DEPRECATED transitional shim — removed in the cleanup wave)
        .library(
            name: "Serializer Primitives Core",
            targets: ["Serializer Primitives Core"]
        ),
        // MARK: - Combinators
        .library(
            name: "Serializer Map Primitives",
            targets: ["Serializer Map Primitives"]
        ),
        .library(
            name: "Serializer Filter Primitives",
            targets: ["Serializer Filter Primitives"]
        ),
        .library(
            name: "Serializer Optional Primitives",
            targets: ["Serializer Optional Primitives"]
        ),
        .library(
            name: "Serializer Many Primitives",
            targets: ["Serializer Many Primitives"]
        ),
        .library(
            name: "Serializer Sequence Primitives",
            targets: ["Serializer Sequence Primitives"]
        ),
        .library(
            name: "Serializer Literal Primitives",
            targets: ["Serializer Literal Primitives"]
        ),
        .library(
            name: "Serializer Always Primitives",
            targets: ["Serializer Always Primitives"]
        ),
        .library(
            name: "Serializer Fail Primitives",
            targets: ["Serializer Fail Primitives"]
        ),
        .library(
            name: "Serializer Lazy Primitives",
            targets: ["Serializer Lazy Primitives"]
        ),
        .library(
            name: "Serializer Trace Primitives",
            targets: ["Serializer Trace Primitives"]
        ),
        // MARK: - Standard Library Integration
        .library(
            name: "Serializer Primitives Standard Library Integration",
            targets: ["Serializer Primitives Standard Library Integration"]
        ),
        // MARK: - Umbrella
        .library(
            name: "Serializer Primitives",
            targets: ["Serializer Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace
        .target(
            name: "Serializer Primitive",
            dependencies: []
        ),
        // MARK: - Tagged Integration
        .target(
            name: "Serializer Tagged Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
            ]
        ),
        // MARK: - Witness (closure-backed leaf conformer)
        // Hosted in its OWN target (NOT in "Serializer Primitive") so the module that
        // DEFINES Serializer.Protocol contains no `Body == Never` conformer. With an
        // in-defining-module leaf conformer present, the `@inlinable` leaf-default
        // `var body: Never` `read` accessor is serialized into Serializer_Primitive and
        // re-emitted BODYLESS into every consumer module conforming a `Body == Never`
        // type (Trace, Map, …) — a SIL-verification crash on Windows + Embedded.
        // Relocating the only such conformer (Serializer.Witness) out of the defining
        // module is the verified fix. See:
        //   swift-institute/Issues/swift-issue-noncopyable-assoctype-never-bodyless-witness
        .target(
            name: "Serializer Witness Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        // MARK: - Core (DEPRECATED transitional shim — exports-only; removed in the cleanup wave)
        .target(
            name: "Serializer Primitives Core",
            dependencies: [
                "Serializer Primitive",
                "Serializer Tagged Primitives",
                "Serializer Witness Primitives",
            ]
        ),
        // MARK: - Combinators
        .target(
            name: "Serializer Map Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .target(
            name: "Serializer Filter Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .target(
            name: "Serializer Optional Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        .target(
            name: "Serializer Many Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .target(
            name: "Serializer Sequence Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .target(
            name: "Serializer Literal Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),
        .target(
            name: "Serializer Always Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        .target(
            name: "Serializer Fail Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        .target(
            name: "Serializer Lazy Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        .target(
            name: "Serializer Trace Primitives",
            dependencies: [
                "Serializer Primitive",
            ]
        ),
        // MARK: - Standard Library Integration
        .target(
            name: "Serializer Primitives Standard Library Integration",
            dependencies: [
                "Serializer Primitive",
                "Serializer Optional Primitives",
            ]
        ),
        // MARK: - Umbrella
        .target(
            name: "Serializer Primitives",
            dependencies: [
                "Serializer Primitive",
                "Serializer Tagged Primitives",
                "Serializer Witness Primitives",
                "Serializer Map Primitives",
                "Serializer Filter Primitives",
                "Serializer Optional Primitives",
                "Serializer Many Primitives",
                "Serializer Sequence Primitives",
                "Serializer Literal Primitives",
                "Serializer Always Primitives",
                "Serializer Fail Primitives",
                "Serializer Lazy Primitives",
                "Serializer Trace Primitives",
                "Serializer Primitives Standard Library Integration",
            ]
        ),

        // MARK: - Tests
        // Per [TEST-033]: one test target per source target. Each test
        // target depends on the MINIMAL set of source targets needed to
        // exercise that source target's surface — so per-target link
        // failures (e.g., witness-table emission specific to one source
        // target) are not masked by bundling.
        .testTarget(
            name: "Serializer Primitive Tests",
            dependencies: ["Serializer Primitive", "Serializer Witness Primitives"]
        ),
        .testTarget(
            name: "Serializer Primitives Core Tests",
            dependencies: ["Serializer Primitive", "Serializer Witness Primitives"]
        ),
        .testTarget(
            name: "Serializer Map Primitives Tests",
            dependencies: ["Serializer Map Primitives", "Serializer Witness Primitives"]
        ),
        .testTarget(
            name: "Serializer Filter Primitives Tests",
            dependencies: ["Serializer Filter Primitives", "Serializer Witness Primitives"]
        ),
        .testTarget(
            name: "Serializer Sequence Primitives Tests",
            dependencies: ["Serializer Sequence Primitives", "Serializer Witness Primitives"]
        ),
        .testTarget(
            name: "Serializer Literal Primitives Tests",
            dependencies: ["Serializer Literal Primitives"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
