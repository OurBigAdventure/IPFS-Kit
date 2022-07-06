// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "IPFSKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "IPFSKit",
            targets: ["IPFSKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IPFSKit",
            dependencies: []),
    ]
)
