// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The package definition.
let package = Package(
    name: "VHDLParsing",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other
        // packages.
        .library(
            name: "VHDLParsing",
            targets: ["VHDLParsing"]
        ),
        .library(
            name: "StringHelpers",
            targets: ["StringHelpers"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package
        // depends on.
        .target(
            name: "StringHelpers",
            dependencies: []
        ),
        .target(
            name: "VHDLParsing",
            dependencies: [.target(name: "StringHelpers")]
        ),
        .testTarget(
            name: "StringHelpersTests",
            dependencies: [.target(name: "StringHelpers")]
        ),
        .testTarget(
            name: "VHDLParsingTests",
            dependencies: [.target(name: "VHDLParsing"), .target(name: "StringHelpers")]
        )
    ]
)
