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
        .library(name: "Serializer", targets: ["Serializer"]),
        .library(name: "Serializer Witness", targets: ["Serializer Witness"]),
        .library(name: "Serializer Error", targets: ["Serializer Error"]),
        .library(name: "Serializer Map", targets: ["Serializer Map"]),
        .library(name: "Serializer Filter", targets: ["Serializer Filter"]),
        .library(name: "Serializer Sequence", targets: ["Serializer Sequence"]),
        .library(name: "Serializer Fail", targets: ["Serializer Fail"]),
        .library(name: "Serializer Trace", targets: ["Serializer Trace"]),
        .library(
            name: "Serializer Standard Library Integration",
            targets: ["Serializer Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-predicate.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(name: "Serializer"),
        .target(
            name: "Serializer Witness",
            dependencies: [.target(name: "Serializer")]
        ),
        .target(
            name: "Serializer Error",
            dependencies: [.target(name: "Serializer")]
        ),
        .target(
            name: "Serializer Map",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Filter",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Predicate", package: "swift-predicate"),
            ]
        ),
        .target(
            name: "Serializer Sequence",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Serializer Fail",
            dependencies: [.target(name: "Serializer")]
        ),
        .target(
            name: "Serializer Trace",
            dependencies: [.target(name: "Serializer")]
        ),
        .target(
            name: "Serializer Standard Library Integration",
            dependencies: [.target(name: "Serializer")]
        ),
        .testTarget(
            name: "Serializer Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Witness"),
            ]
        ),
        .testTarget(
            name: "Serializer Map Tests",
            dependencies: [
                .target(name: "Serializer Map"),
                .target(name: "Serializer Witness"),
            ]
        ),
        .testTarget(
            name: "Serializer Filter Tests",
            dependencies: [
                .target(name: "Serializer Filter"),
                .target(name: "Serializer Witness"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Predicate", package: "swift-predicate"),
            ]
        ),
        .testTarget(
            name: "Serializer Sequence Tests",
            dependencies: [
                .target(name: "Serializer Sequence"),
                .target(name: "Serializer Witness"),
            ]
        ),
        .testTarget(
            name: "Serializer Standard Library Integration Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Standard Library Integration"),
                .target(name: "Serializer Witness"),
            ]
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
