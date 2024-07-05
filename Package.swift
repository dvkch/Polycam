// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPTZ",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "SwiftPTZ",
            targets: ["SwiftPTZ"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        .package(url: "https://github.com/mredig/SwiftSerial.git", from: "0.1.4")
    ],
    targets: [
        .executableTarget(
            name: "SwiftPTZ",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSerial", package: "swiftserial")            ]
        ),
        .testTarget(
            name: "SwiftPTZTests",
            dependencies: ["SwiftPTZ"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
