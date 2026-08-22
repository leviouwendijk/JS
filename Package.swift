// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JS",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "JS",
            targets: [
                "JS",
            ]
        ),
        .executable(
            name: "jstest",
            targets: [
                "JSTestFlows",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/DSL.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/TestFlows.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "JS",
            dependencies: [
                .product(
                    name: "DSL",
                    package: "DSL"
                ),
            ]
        ),
        .executableTarget(
            name: "JSTestFlows",
            dependencies: [
                "JS",
                .product(
                    name: "DSL",
                    package: "DSL"
                ),
                .product(
                    name: "TestFlows",
                    package: "TestFlows"
                ),
            ]
        ),
    ]
)
