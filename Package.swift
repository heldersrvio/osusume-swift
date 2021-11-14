// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "osusume-swift",
    products: [
        .library(
            name: "osusume-swift",
            targets: ["osusume-swift"]),
    ],
    dependencies: [
       .package(url: "https://github.com/heldersrvio/matrix-utils-swift.git", from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "osusume-swift",
            dependencies: ["matrix-utils-swift"]),
        .testTarget(
            name: "osusume-swiftTests",
            dependencies: ["osusume-swift"]),
    ],
    swiftLanguageVersions: [.v5]
)
