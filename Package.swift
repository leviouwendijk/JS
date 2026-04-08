// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JS",
    products: [
        .library(
            name: "JS",
            targets: ["JS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/DSL.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "JS",
            dependencies: [
                .product(name: "DSL", package: "DSL"),
            ],
        ),
        .testTarget(
            name: "JSTests",
            dependencies: ["JS"]
        ),
    ]
)
