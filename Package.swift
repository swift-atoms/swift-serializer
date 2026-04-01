// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-serializer-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Core
        .library(
            name: "Serializer Primitives Core",
            targets: ["Serializer Primitives Core"]
        ),
        // MARK: - Witnesses
        .library(
            name: "Serialization Primitives",
            targets: ["Serialization Primitives"]
        ),
        // MARK: - Umbrella
        .library(
            name: "Serializer Primitives",
            targets: ["Serializer Primitives"]
        ),
        .library(
            name: "Serialization Primitives Test Support",
            targets: ["Serialization Primitives Test Support"]
        ),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Serializer Primitives Core"
        ),
        // MARK: - Witnesses
        .target(
            name: "Serialization Primitives"
        ),
        // MARK: - Umbrella
        .target(
            name: "Serializer Primitives",
            dependencies: [
                "Serializer Primitives Core",
                "Serialization Primitives",
            ]
        ),
        .testTarget(
            name: "Serialization Primitives Tests",
            dependencies: [
                "Serialization Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Serialization Primitives Test Support",
            dependencies: [
                "Serialization Primitives",
            ],
            path: "Tests/Support"
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
