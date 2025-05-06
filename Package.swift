// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JTPromiseKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "JTPromiseKit",
            targets: ["JTPromiseKit"]
        ),
    ],
    targets: [
        .target(name: "JTPromiseKit")
    ],
    swiftLanguageVersions: [.v5]
)
