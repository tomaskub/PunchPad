// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TabViewKit",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "TabViewKit",
            targets: ["TabViewKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TabViewKit",
            dependencies:[],
            path: "./Sources/"
        )
    ]
)
