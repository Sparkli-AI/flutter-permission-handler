// swift-tools-version: 5.9

import PackageDescription

// TODO: Drop this fork after upstream #1544 is fixed; see README.md.
// Odyssey enables only microphone access in every flavor.
let package = Package(
    name: "permission_handler_apple",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "permission-handler-apple", targets: ["permission_handler_apple"]),
    ],
    dependencies: [
        .package(path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "permission_handler_apple",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [.process("PrivacyInfo.xcprivacy")],
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("strategies"),
                .headerSearchPath("util"),
                .define("PERMISSION_MICROPHONE"),
            ]
        ),
    ]
)
