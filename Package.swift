// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-iterator-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Iterator Primitive",
            targets: ["Iterator Primitive"]
        ),

        .library(
            name: "Iterator Protocol",
            targets: ["Iterator Protocol"]
        ),

        .library(
            name: "Iterator Witness Primitives",
            targets: ["Iterator Witness Primitives"]
        ),

        .library(
            name: "Iterable",
            targets: ["Iterable"]
        ),

        .library(
            name: "Iterator Once Primitives",
            targets: ["Iterator Once Primitives"]
        ),

        .library(
            name: "Iterator Chunk Primitives",
            targets: ["Iterator Chunk Primitives"]
        ),

        .library(
            name: "Iterator Primitives",
            targets: ["Iterator Primitives"]
        ),

        .library(
            name: "Iterator Primitives Test Support",
            targets: ["Iterator Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-carrier-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-cardinal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Iterator Primitive",
            dependencies: []
        ),

        .target(
            name: "Iterator Protocol",
            dependencies: [
                "Iterator Primitive"
            ]
        ),

        .target(
            name: "Iterator Witness Primitives",
            dependencies: [
                "Iterator Protocol"
            ]
        ),

        .target(
            name: "Iterable",
            dependencies: [
                "Iterator Protocol",
                "Iterator Chunk Primitives",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
            ]
        ),

        .target(
            name: "Iterator Once Primitives",
            dependencies: [
                "Iterator Protocol"
            ]
        ),

        .target(
            name: "Iterator Chunk Primitives",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                .product(name: "Carrier Primitives", package: "swift-carrier-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(
                    name: "Cardinal Primitives Standard Library Integration",
                    package: "swift-cardinal-primitives"
                ),
            ]
        ),

        .target(
            name: "Iterator Primitives",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                "Iterator Witness Primitives",
                "Iterable",
                "Iterator Once Primitives",
                "Iterator Chunk Primitives",
            ]
        ),

        .target(
            name: "Iterator Primitives Test Support",
            dependencies: [
                "Iterator Primitives"
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Iteration Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterator Once Primitives Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterator Chunk Primitives Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterable Tests",
            dependencies: ["Iterator Primitives Test Support"]
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
