// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]),

//        .library(
//            name: "Persistance",
//            targets: ["Persistance"]
//        )
    ],
    targets: [
        .target(
            name: "UIComponents"),
//        .target(name: "Persistance"),
//        .testTarget(
//            name: "PeristanceTests",
//            dependencies: ["Core"]
//        )
    ]
)
