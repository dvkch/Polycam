// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PTZ",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "ptz",
            targets: ["PTZCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        .package(url: "https://github.com/mredig/SwiftSerial.git", from: "0.1.4"),
        .package(url: "https://github.com/Jomy10/SwiftCurses.git", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "PTZCLI",
            dependencies: [
                .target(name: "PTZCamera"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftCurses", package: "SwiftCurses"),
            ]
        ),
        .target(name: "PTZCommon", dependencies: []),
        .target(name: "PTZCamera", dependencies: [
            .target(name: "PTZMessaging"),
            .target(name: "PTZCommon"),
        ]),
        .target(name: "PTZMessaging", dependencies: [
            .product(name: "SwiftSerial", package: "swiftserial"),
            .target(name: "PTZCommon"),
        ]),
        .testTarget(
            name: "PTZCameraTests",
            dependencies: ["PTZCamera"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
