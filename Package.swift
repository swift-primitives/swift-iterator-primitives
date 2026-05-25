// swift-tools-version: 6.3.1

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
            name: "Iterate",
            targets: ["Iterate"]
        ),

        // MARK: - Attachable
        .library(
            name: "Iterable",
            targets: ["Iterable"]
        ),

        // MARK: - Concrete Iterators
        .library(
            name: "Iterator Empty Primitives",
            targets: ["Iterator Empty Primitives"]
        ),
        .library(
            name: "Iterator Once Primitives",
            targets: ["Iterator Once Primitives"]
        ),
        .library(
            name: "Iterator Repeating Primitives",
            targets: ["Iterator Repeating Primitives"]
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
    dependencies: [],
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
            name: "Iterate",
            dependencies: [
                "Iterator Protocol",
            ]
        ),

        // MARK: - Attachable
        .target(
            name: "Iterable",
            dependencies: [
                "Iterator Protocol",
            ]
        ),

        // MARK: - Concrete Iterators
        .target(
            name: "Iterator Empty Primitives",
            dependencies: [
                "Iterator Protocol",
            ]
        ),
        .target(
            name: "Iterator Once Primitives",
            dependencies: [
                "Iterator Protocol",
            ]
        ),
        .target(
            name: "Iterator Repeating Primitives",
            dependencies: [
                "Iterator Protocol",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Iterator Primitives",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                "Iterate",
                "Iterable",
                "Iterator Empty Primitives",
                "Iterator Once Primitives",
                "Iterator Repeating Primitives",
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
            name: "Iterate Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterator Empty Primitives Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterator Once Primitives Tests",
            dependencies: ["Iterator Primitives Test Support"]
        ),
        .testTarget(
            name: "Iterator Repeating Primitives Tests",
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
