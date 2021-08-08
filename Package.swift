// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuccessionsKrigen",
    platforms: [.macOS(.v11)],
    products: [
         // Products define the executables and libraries a package produces, and make them visible to other packages.
         .library(
             name: "SuccessionsKrigen",
             targets: ["SuccessionsKrigen"]),
     ],
    dependencies: [
        .package(name: "SwiftSDL", url: "https://github.com/KevinVitale/SwiftSDL", .branch("master"))
//        .package(name: "SDL2", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "SuccessionsKrigen",
            dependencies: []
        ),
        .target(
            name: "SuccessionsKrigenSDLExample",
            dependencies: [
                "SuccessionsKrigen",
                .product(name: "SwiftSDL2", package: "SwiftSDL")
//                "SDL2"
            ]),
        .testTarget(
            name: "SuccessionsKrigenTests",
            dependencies: ["SuccessionsKrigen"]),
        .testTarget(
            name: "SuccessionsKrigenSDLExampleTests",
            dependencies: ["SuccessionsKrigenSDLExample"]),
    ]
)
