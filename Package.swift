// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuccessionsKrigen",
    platforms: [.macOS(.v11)],
    dependencies: [
        .package(name: "SwiftSDL", url: "https://github.com/KevinVitale/SwiftSDL", .branch("master"))
    ],
    targets: [
        .target(
            name: "HoMM2Engine",
            dependencies: []
        ),
        .target(
            name: "SuccessionsKrigen",
            dependencies: [
                "HoMM2Engine",
                .product(name: "SwiftSDL2", package: "SwiftSDL")
            ]),
        .testTarget(
            name: "HoMM2EngineTests",
            dependencies: ["HoMM2Engine"]),
        .testTarget(
            name: "SuccessionsKrigenTests",
            dependencies: ["SuccessionsKrigen"]),
    ]
)
