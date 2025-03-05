// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Detail",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Detail",
            targets: ["Detail"]),
    ],
    dependencies: [
        .package(path: "DataBase"),
        .package(path: "Extensions"),
        .package(path: "Reader"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Detail",
            dependencies: [
                "DataBase",
                "Extensions",
                "Reader",
                "Kingfisher",
            ]
        ),
    ]
)
