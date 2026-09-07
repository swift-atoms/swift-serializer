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
                .product(name: "Either", package: "swift-either"),
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
                .product(name: "Either", package: "swift-either"),
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
