// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "TimerServiceInterfaces",
            targets: ["TimerServiceInterfaces"]
        ),
        .library(
            name: "TimerService",
            targets: ["TimerService"]
        ),
        .library(
            name: "TimerServiceMocks",
            targets: ["TimerServiceMocks"]
        ),
        .library(
            name: "NotificationService",
            targets: ["NotificationService"]
        )
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(name: "TimerServiceInterfaces"),
        .target(
            name: "TimerService",
            dependencies: [
                .target(name: "TimerServiceInterfaces"),
                .product(
                    name: "DomainModels",
                    package: "Core"
                )
            ]
        ),
        .target(
            name: "TimerServiceMocks",
            dependencies: [
                .target(name: "TimerServiceInterfaces")
            ]
        ),
        .testTarget(
            name: "TimerServiceTests",
            dependencies: ["TimerService"]
        ),
        .target(
            name: "NotificationService",
            dependencies: [
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "FoundationExtensions",
                    package: "Core"
                )
            ]
        )
    ]
)
