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

        .library(name: "Serializer Foundation Integration", targets: ["Serializer Foundation Integration"]),
        .library(name: "Serializer Test Support", targets: ["Serializer Test Support"]),
    ],
    traits: [
        .trait(name: "Either", description: "Serialization integration for Either"),
        .trait(name: "Map", description: "Borrowed serialization contramaps", enabledTraits: ["Either"]),
        .trait(name: "Pair", description: "Structural serialization products", enabledTraits: ["Either"]),
        .trait(name: "Optic", description: "Serialization integration for Optic", enabledTraits: ["Map"]),
        .trait(name: "Always", description: "Discarding serialization for Always"),
        .trait(name: "Lazy", description: "Deferred serialization factories", enabledTraits: ["Either"]),
        .trait(name: "Tagged", description: "Serialization of tagged values"),
        .trait(name: "Collection", description: "Fresh collection serialization buffers"),
        .trait(name: "Repetition", description: "Bounded and separated serialization", enabledTraits: ["Either"]),
        .default(enabledTraits: ["Either", "Map", "Pair", "Optic", "Always", "Lazy", "Tagged", "Collection", "Repetition"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-repetition.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-always.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-lazy.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-map.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Serializer",
            dependencies: [
                .product(name: "Repetition", package: "swift-repetition", condition: .when(traits: ["Repetition"])),
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["Repetition"])),
                .product(name: "Always", package: "swift-always", condition: .when(traits: ["Always"])),
                .product(name: "Lazy", package: "swift-lazy", condition: .when(traits: ["Lazy"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Tagged"])),
                .product(name: "Either", package: "swift-either", condition: .when(traits: ["Either"])),
                .product(name: "Map", package: "swift-map", condition: .when(traits: ["Map"])),
                .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Pair"])),
                .product(name: "Optic", package: "swift-optic", condition: .when(traits: ["Optic"])),
            ],
            path: "Sources/Serializer"
        ),
        
        .target(
            name: "Serializer Foundation Integration",
            dependencies: [
                .target(name: "Serializer"),
            ],
            path: "Sources/Serializer Foundation Integration"
        ),
        .target(
            name: "Serializer Test Support",
            dependencies: [
                .target(name: "Serializer"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Serializer Tests",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Either", package: "swift-either", condition: .when(traits: ["Either"])),
                .target(name: "Serializer Test Support"),
                .target(name: "Serializer Foundation Integration"),
            ],
            path: "Tests/Serializer Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
