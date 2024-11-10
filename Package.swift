// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

var nCursesDependency: [PackageDescription.Target.Dependency] = []
#if os(macOS)
nCursesDependency.append(.product(name: "SwiftCurses", package: "SwiftCurses"))
#endif

let package = Package(
    name: "PTZ",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ptz", targets: ["PTZ"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        .package(url: "https://github.com/mredig/SwiftSerial.git", from: "0.1.4"),
        .package(url: "https://github.com/Jomy10/SwiftCurses.git", branch: "master"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "510.0.3"),
    ],
    targets: [
        .executableTarget(name: "PTZ", dependencies: [
                .target(name: "PTZCamera"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ] + nCursesDependency),
        .target(name: "PTZCamera", dependencies: [
            .target(name: "PTZMessaging"),
            .target(name: "PTZCameraMacros"),
        ]),
        .target(name: "PTZMessaging", dependencies: [
            .product(name: "SwiftSerial", package: "swiftserial"),
        ]),
        .macro(name: "PTZCameraMacros", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .testTarget(name: "PTZCameraTests", dependencies: ["PTZCamera"], resources: [
            .copy("Fixtures/Data")
        ]),
        .testTarget(name: "PTZTests", dependencies: ["PTZ"])
    ]
)
