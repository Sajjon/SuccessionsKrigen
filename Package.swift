// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuccessionsKrigen",
    platforms: [.macOS(.v11)],
    dependencies: [
        .package(name: "SwiftSDL", url: "https://github.com/KevinVitale/SwiftSDL", .branch("master"))
//        .package(name: "SDL2", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.2.0")
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
//                "SDL2"
            ]),
        .testTarget(
            name: "HoMM2EngineTests",
            dependencies: ["HoMM2Engine"]),
        .testTarget(
            name: "SuccessionsKrigenTests",
            dependencies: ["SuccessionsKrigen"]),
    ]
)
