# VHDLParsing

[![Swift Coverage Test](https://github.com/mipalgu/VHDLParsing/actions/workflows/cov.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/cov.yml)
[![Ubuntu 20.04 Swift Debug CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-debug.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-debug.yml)
[![Ubuntu 20.04 Swift Release CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-release.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-release.yml)
[![Ubuntu 22.04 Swift Debug CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-debug-22_04.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-debug-22_04.yml)
[![Ubuntu 22.04 Swift Release CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-release-22_04.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-linux-release-22_04.yml)
[![MacOS Monterey Swift Debug CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS-debug.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS-debug.yml)
[![MacOS Monterey Swift Release CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS-release.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS-release.yml)
[![Swift Lint](https://github.com/mipalgu/VHDLParsing/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/swiftlint.yml)
[![MacOS Ventura Swift Debug CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS13-debug.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS13-debug.yml)
[![MacOS Ventura Swift Release CI](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS13-release.yml/badge.svg)](https://github.com/mipalgu/VHDLParsing/actions/workflows/ci-macOS13-release.yml)


A `VHDL` parser written in `Swift`. This package parses `VHDL` files into a model that can be
used in other projects. This parser is not complete and is not intended to have full compatibility with the
entire `VHDL` language. It is intended to be used in other `mipalgu` projects, where parsing the entire `VHDL`
language is not required to achieve intended outcomes.

Most structures in `VHDL` have corresponding types in this package that conform to `RawRepresentable`. To
parse an entire file, you may use the `VHDLFile` struct, passing the contents of a `VHDL` file to its `init`
method.

```swift
guard
    // Read contents of file
    let contents = try? String(contentsOfFile: URL(fileURLWithPath: "path/to/file.vhd", isDirectory: false))
    let file = VHDLFile(rawValue: contents) // VHDL structure.
else {
    // Handle error.
}
let includes: [Include] = file.includes // includes.
let entities: [Entity] = file.entities // entity blocks.
let architectures: [Architecture] = file.architectures // architecture blocks.
let packages: [VHDLPackage] = file.packages // package definitions.
```

Please see the `About` section of this repository on `GitHub` for the latest documentation.

## Requirements

- Swift 5.7 or later.
- macOS 12 or later.
- Linux (Ubuntu 20.04 or later).

## Usage

To use this package, it is preferred that you use the `Swift Package Manager`. To do so, add the following
lines to your package manifest.

```swift
// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["VHDLParsing"]),
        .testTarget(
            name: "MyPackageTests",
            dependencies: ["MyPackage", "VHDLParsing"]),
    ]
)
```

## Contributing

I am happy to accept pull requests to support more of the `VHDL` language. Please ensure that you have passing
workflows before you request a review. If you are unsure about the implementation, please open an issue, and I
will be happy to discuss it with you.
