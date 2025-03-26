// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DialerTO",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DialerTO",
            targets: ["DialerTOFramework"]),
    ],
    targets: [
        .binaryTarget(
            name: "DialerTOFramework",
            url: "https://github.com/cedricbahirwe/DialerOptimizer/releases/download/v1/DialerTO.xcframework.zip",
            checksum: "bfcc8ab9f3a63830c06612b6423efe266b8d2a47fa0e02b51f0cdeb0f93c0a88"
        )
    ]
)
