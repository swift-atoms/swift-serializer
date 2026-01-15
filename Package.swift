// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-serialization-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Serialization Primitives",
            targets: ["Serialization Primitives"]
        ),
    ],
    targets: [
        .target(
            name: "Serialization Primitives"
        ),
        .testTarget(
            name: "Serialization Primitives Tests",
            dependencies: [
                "Serialization Primitives",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
