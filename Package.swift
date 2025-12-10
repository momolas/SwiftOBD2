// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-OBD2",
    platforms: [
        .iOS("26.0"),
        .macOS("16.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Swift-OBD2",
            targets: ["Swift-OBD2"]
        )
    ],
//    dependencies: [
//        // ...
//        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2"),
//    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Swift-OBD2"
//            plugins: [
//                .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
//            ]
        ),
        .testTarget(
            name: "Swift-OBD2Tests",
            dependencies: ["Swift-OBD2"]
        )
    ]
)
