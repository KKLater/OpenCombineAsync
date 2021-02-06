// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenCombineAsync",
    platforms: [.macOS("10.10"), .iOS("9.0"), .tvOS("9.0"), .watchOS("2.0")],
    products: [
        .library(name: "OpenCombineAsync", targets: ["OpenCombineAsync"]),
    ],
    dependencies: [
        .package(url: "https://github.com/broadwaylamb/OpenCombine", .upToNextMinor(from: "0.11.0"))
    ],
    targets: [
        .target(name: "OpenCombineAsync", dependencies: ["OpenCombine"]),
        .testTarget(name: "OpenCombineAsyncTests", dependencies: ["OpenCombineAsync"]),
    ],
    swiftLanguageVersions: [.v5]
)
