// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-serializer",
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
            name: "Serializer Tagged",
            targets: ["Serializer Tagged"]
        ),

        .library(
            name: "Serializer Witness",
            targets: ["Serializer Witness"]
        ),

        .library(
            name: "Serializer Core",
            targets: ["Serializer Core"]
        ),

        .library(
            name: "Serializer Map",
            targets: ["Serializer Map"]
        ),
        .library(
            name: "Serializer Filter",
            targets: ["Serializer Filter"]
        ),
        .library(
            name: "Serializer Optional",
            targets: ["Serializer Optional"]
        ),
        .library(
            name: "Serializer Many",
            targets: ["Serializer Many"]
        ),
        .library(
            name: "Serializer Sequence",
            targets: ["Serializer Sequence"]
        ),
        .library(
            name: "Serializer Literal",
            targets: ["Serializer Literal"]
        ),
        .library(
            name: "Serializer Always",
            targets: ["Serializer Always"]
        ),
        .library(
            name: "Serializer Fail",
            targets: ["Serializer Fail"]
        ),
        .library(
            name: "Serializer Lazy",
            targets: ["Serializer Lazy"]
        ),
        .library(
            name: "Serializer Trace",
            targets: ["Serializer Trace"]
        ),

        .library(
            name: "Serializer Standard Library Integration",
            targets: ["Serializer Standard Library Integration"]
        ),

        .library(
            name: "Serializer",
            targets: ["Serializer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Serializer Primitive",
            dependencies: []
        ),

        .target(
            name: "Serializer Tagged",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Serializer Witness",
            dependencies: [
                "Serializer Primitive"
            ]
        ),

        .target(
            name: "Serializer Core",
            dependencies: [
                "Serializer Primitive",
                "Serializer Tagged",
                "Serializer Witness",
            ]
        ),

        .target(
            name: "Serializer Map",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Filter",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Optional",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Many",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Sequence",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Literal",
            dependencies: [
                "Serializer Primitive",
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .target(
            name: "Serializer Always",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Fail",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Lazy",
            dependencies: [
                "Serializer Primitive"
            ]
        ),
        .target(
            name: "Serializer Trace",
            dependencies: [
                "Serializer Primitive"
            ]
        ),

        .target(
            name: "Serializer Standard Library Integration",
            dependencies: [
                "Serializer Primitive",
                "Serializer Optional",
            ]
        ),

        .target(
            name: "Serializer",
            dependencies: [
                "Serializer Primitive",
                "Serializer Tagged",
                "Serializer Witness",
                "Serializer Map",
                "Serializer Filter",
                "Serializer Optional",
                "Serializer Many",
                "Serializer Sequence",
                "Serializer Literal",
                "Serializer Always",
                "Serializer Fail",
                "Serializer Lazy",
                "Serializer Trace",
                "Serializer Standard Library Integration",
            ]
        ),

        .testTarget(
            name: "Serializer Primitive Tests",
            dependencies: ["Serializer Primitive", "Serializer Witness"]
        ),
        .testTarget(
            name: "Serializer Core Tests",
            dependencies: ["Serializer Primitive", "Serializer Witness"]
        ),
        .testTarget(
            name: "Serializer Map Tests",
            dependencies: ["Serializer Map", "Serializer Witness"]
        ),
        .testTarget(
            name: "Serializer Filter Tests",
            dependencies: ["Serializer Filter", "Serializer Witness"]
        ),
        .testTarget(
            name: "Serializer Sequence Tests",
            dependencies: ["Serializer Sequence", "Serializer Witness"]
        ),
        .testTarget(
            name: "Serializer Literal Tests",
            dependencies: ["Serializer Literal"]
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
