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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SuccessionsKrigen",
            dependencies: [.product(name: "SwiftSDL2", package: "SwiftSDL")]),
        .testTarget(
            name: "SuccessionsKrigenTests",
            dependencies: ["SuccessionsKrigen"]),
    ]
)
