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
            name: "Serializer",
            targets: ["Serializer"]
        ),
        .library(
            name: "Serializer Standard Library Integration",
            targets: ["Serializer Standard Library Integration"]
        ),
        .library(
            name: "Serializer Apple Foundation Integration",
            targets: ["Serializer Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Serializer",
            dependencies: [
                .product(name: "Either", package: "swift-either")
            ]
        ),
        .target(
            name: "Serializer Standard Library Integration",
            dependencies: ["Serializer"]
        ),
        .target(
            name: "Serializer Apple Foundation Integration",
            dependencies: [
                "Serializer",
                "Serializer Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Serializer Tests",
            dependencies: [
                "Serializer",
                .product(name: "Either", package: "swift-either"),
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
