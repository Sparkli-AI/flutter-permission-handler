// swift-tools-version: 5.9

import PackageDescription

// TODO(SPRK-1975): Drop Odyssey's microphone-only manifest; see README.md.
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
