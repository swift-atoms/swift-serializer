// swift-tools-version: 6.2

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
        // MARK: - Concrete Serializers
        .library(
            name: "Serializer ASCII Integer Primitives",
            targets: ["Serializer ASCII Integer Primitives"]
        ),
        // MARK: - Conformances
        .library(
            name: "Serializable Integer Primitives",
            targets: ["Serializable Integer Primitives"]
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
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Serializer Primitives Core"
        ),
        // MARK: - Concrete Serializers
        .target(
            name: "Serializer ASCII Integer Primitives",
            dependencies: [
                "Serializer Primitives Core",
            ]
        ),
        // MARK: - Conformances
        .target(
            name: "Serializable Integer Primitives",
            dependencies: [
                "Serializer ASCII Integer Primitives",
            ]
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
                "Serializer ASCII Integer Primitives",
                "Serializable Integer Primitives",
                "Serialization Primitives",
            ]
        ),
        .testTarget(
            name: "Serialization Primitives Tests",
            dependencies: [
                "Serialization Primitives",
            ]
        ),
        .testTarget(
            name: "Serializer ASCII Integer Primitives Tests",
            dependencies: [
                "Serializer ASCII Integer Primitives",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
