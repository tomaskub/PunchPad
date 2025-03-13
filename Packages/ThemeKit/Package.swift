// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ThemeKit",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "ThemeKit",
            targets: ["ThemeKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ThemeKit",
            dependencies:[],
            path: "Sources",
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/ColorAssets.xcassets")
            ]
        )
    ]
)
