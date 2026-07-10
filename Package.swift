// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-iterator-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Namespace
        .library(
            name: "Iterator Primitive",
            targets: ["Iterator Primitive"]
        ),

        // MARK: - Protocol
        .library(
            name: "Iterator Protocol",
            targets: ["Iterator Protocol"]
        ),

        // MARK: - Witness
        .library(
            name: "Iterator Witness Primitives",
            targets: ["Iterator Witness Primitives"]
        ),

        // MARK: - Attachable
        .library(
            name: "Iterable",
            targets: ["Iterable"]
        ),

        // MARK: - Concrete Iterators
        .library(
            name: "Iterator Once Primitives",
            targets: ["Iterator Once Primitives"]
        ),

        // MARK: - Bulk tier
        .library(
            name: "Iterator Chunk Primitives",
            targets: ["Iterator Chunk Primitives"]
        ),

        // MARK: - Umbrella
        .library(
            name: "Iterator Primitives",
            targets: ["Iterator Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Iterator Primitives Test Support",
            targets: ["Iterator Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-carrier-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-cardinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace
        .target(
            name: "Iterator Primitive",
            dependencies: []
        ),

        // MARK: - Protocol
        .target(
            name: "Iterator Protocol",
            dependencies: [
                "Iterator Primitive",
            ]
        ),

        // MARK: - Witness
        .target(
            name: "Iterator Witness Primitives",
            dependencies: [
                "Iterator Protocol",
            ]
        ),

        // MARK: - Attachable
        .target(
            name: "Iterable",
            dependencies: [
                "Iterator Protocol",
                "Iterator Chunk Primitives",
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
            ]
        ),

        // MARK: - Concrete Iterators
        .target(
            name: "Iterator Once Primitives",
            dependencies: [
                "Iterator Protocol",
            ]
        ),

        // MARK: - Bulk tier
        .target(
            name: "Iterator Chunk Primitives",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                .product(name: "Carrier Primitives", package: "swift-carrier-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Cardinal Primitives Standard Library Integration", package: "swift-cardinal-primitives"),
            ]
        ),

        // MARK: - Umbrella
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

        // MARK: - Test Support
        .target(
            name: "Iterator Primitives Test Support",
            dependencies: [
                "Iterator Primitives",
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
