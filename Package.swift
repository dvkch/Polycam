// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "PTZ",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ptz", targets: ["PTZ"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/mredig/SwiftSerial.git", from: "0.1.5"),
        .package(url: "https://github.com/Jomy10/SwiftCurses.git", branch: "master"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "PTZ",
            dependencies: [
                .target(name: "PTZCamera"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftCurses", package: "SwiftCurses"),
            ]
        ),
        .target(
            name: "PTZCamera",
            dependencies: [
                .target(name: "PTZMessaging"),
                .target(name: "PTZCameraMacros"),
            ]
        ),
        .target(
            name: "PTZMessaging",
            dependencies: [
                .product(name: "SwiftSerial", package: "swiftserial")
            ]
        ),
        .macro(
            name: "PTZCameraMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "PTZCameraTests", dependencies: ["PTZCamera"],
            resources: [
                .copy("Fixtures/Data")
            ]
        ),
        .testTarget(name: "PTZTests", dependencies: ["PTZ"]),
    ]
)
