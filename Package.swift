// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftConcurrencyCLI",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-async-algorithms.git",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .executableTarget(
            name: "SwiftConcurrencyCLI",
            dependencies: [
                .product(
                    name: "AsyncAlgorithms",
                    package: "swift-async-algorithms"
                ),
            ],
            path: "Sources"
        ),
    ]
)
