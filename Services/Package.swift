// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "TimerService",
            targets: ["TimerService"]
        )

    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "TimerService",
            dependencies: [
                .product(
                    name: "DomainModels",
                    package: "Core"
                )
            ]
        ),
        .testTarget(
            name: "TimerServiceTests",
            dependencies: ["TimerService"]
        )
    ]
)
