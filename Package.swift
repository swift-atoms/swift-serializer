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
            name: "Serializer Tagged",
            targets: ["Serializer Tagged"]
        ),

        .library(
            name: "Serializer Witness",
            targets: ["Serializer Witness"]
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

    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Serializer",
            dependencies: []
        ),

        .target(
            name: "Serializer Tagged",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Serializer Witness",
            dependencies: [
                .target(name: "Serializer")
            ]
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
            ]
        ),
        .target(
            name: "Serializer Optional",
            dependencies: [
                .target(name: "Serializer")
            ]
        ),
        .target(
            name: "Serializer Many",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Either", package: "swift-either"),
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
            name: "Serializer Literal",
            dependencies: [
                .target(name: "Serializer"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .target(
            name: "Serializer Always",
            dependencies: [
                .target(name: "Serializer")
            ]
        ),
        .target(
            name: "Serializer Fail",
            dependencies: [
                .target(name: "Serializer")
            ]
        ),
        .target(
            name: "Serializer Lazy",
            dependencies: [
                .target(name: "Serializer")
            ]
        ),
        .target(
            name: "Serializer Trace",
            dependencies: [
                .target(name: "Serializer")
            ]
        ),

        .target(
            name: "Serializer Standard Library Integration",
            dependencies: [
                .target(name: "Serializer"),
                .target(name: "Serializer Optional"),
            ]
        ),

        .testTarget(
            name: "Serializer Tests",
            dependencies: [.target(name: "Serializer"), .target(name: "Serializer Witness")]
        ),
        .testTarget(
            name: "Serializer Map Tests",
            dependencies: [.target(name: "Serializer Map"), .target(name: "Serializer Witness")]
        ),
        .testTarget(
            name: "Serializer Filter Tests",
            dependencies: [.target(name: "Serializer Filter"), .target(name: "Serializer Witness")]
        ),
        .testTarget(
            name: "Serializer Sequence Tests",
            dependencies: [.target(name: "Serializer Sequence"), .target(name: "Serializer Witness")]
        ),
        .testTarget(
            name: "Serializer Literal Tests",
            dependencies: [.target(name: "Serializer Literal")]
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
