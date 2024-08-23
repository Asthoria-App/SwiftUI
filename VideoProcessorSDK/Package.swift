// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VideoProcessorSDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "VideoProcessorSDK",
            targets: ["VideoProcessorSDK"]),
    ],
    targets: [
        .target(
            name: "VideoProcessorSDK",
            dependencies: []),
        .testTarget(
            name: "VideoProcessorSDKTests",
            dependencies: ["VideoProcessorSDK"]),
    ]
)
