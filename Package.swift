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
            name: "Serializer Standard Library Integration",
            dependencies: [.target(name: "Serializer")]
        ),
        .testTarget(
            name: "Serializer Tests",
            dependencies: [.target(name: "Serializer")]
        ),
        .testTarget(
            name: "Serializer Witness Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Witness"),
            ]
        ),
        .testTarget(
            name: "Serializer Error Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Error"),
            ]
        ),
        .testTarget(
            name: "Serializer Map Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Map"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .testTarget(
            name: "Serializer Standard Library Integration Tests",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Standard Library Integration"),
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
