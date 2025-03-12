// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NavigationKit",
            dependencies:[],
            path: "./Sources/"
        )
    ]
)
