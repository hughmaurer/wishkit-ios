// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "wishkit-ios",
    defaultLocalization: "fr",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(name: "WishKit", targets: ["WishKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/wishkit/wishkit-ios-shared.git", exact: "1.5.0")
    ],
    targets: [
        .target(
            name: "WishKit",
            dependencies: [
            .product(name: "WishKitShared", package: "wishkit-ios-shared")
            ],
            resources: [
                .process("Resources") // Make sure your model is in this folder
            ]),
        .testTarget(name: "WishKitTests", dependencies: [.target(name: "WishKit")]),
    ]
)
