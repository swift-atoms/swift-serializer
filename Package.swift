// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-serializer-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Serializer Primitive",
            targets: ["Serializer Primitive"]
        ),

        .library(
            name: "Serializer Tagged Primitives",
            targets: ["Serializer Tagged Primitives"]
        ),

        .library(
            name: "Serializer Witness Primitives",
            targets: ["Serializer Witness Primitives"]
        ),

        .library(
            name: "Serializer Primitives Core",
            targets: ["Serializer Primitives Core"]
        ),

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

        .library(
            name: "Serializer Primitives Standard Library Integration",
            targets: ["Serializer Primitives Standard Library Integration"]
        ),

        .library(
            name: "Serializer Primitives",
            targets: ["Serializer Primitives"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Serializer Primitive",
            dependencies: []
        ),

        .target(
            name: "Serializer Tagged Primitives",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
            ]
        ),

        .target(
            name: "Serializer Witness Primitives",
            dependencies: [
                "Serializer Primitive"
            ]
        ),

        .target(
            name: "Serializer Primitives Core",
            dependencies: [
                "Serializer Primitive",
                "Serializer Tagged Primitives",
                "Serializer Witness Primitives",
            ]
        ),

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
                "Serializer Primitive"
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
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Fail Primitives",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Lazy Primitives",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Trace Primitives",
            dependencies: [
                "Serializer Primitive"
            ]
        ),

        .target(
            name: "Serializer Primitives Standard Library Integration",
            dependencies: [
                "Serializer Primitive",
                "Serializer Optional Primitives",
            ]
        ),

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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
