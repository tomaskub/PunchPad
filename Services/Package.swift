// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS("16.6")],
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
            name: "ChartPeriodServiceInterfaces",
            targets: ["ChartPeriodServiceInterfaces"]
        ),
        .library(
            name: "ChartPeriodService",
            targets: ["ChartPeriodService"]
        ),
        .library(
            name: "ChartPeriodServiceMocks",
            targets: ["ChartPeriodServiceMocks"]
        ),
        .library(
            name: "PayServiceInterfaces",
            targets: ["PayServiceInterfaces"]
        ),
        .library(
            name: "PayService",
            targets: ["PayService"]
        ),
        .library(
            name: "PayServiceMocks",
            targets: ["PayServiceMocks"]
        ),
        .library(
            name: "SettingsServiceInterfaces",
            targets: ["SettingsServiceInterfaces"]
        ),
        .library(
            name: "SettingsService",
            targets: ["SettingsService"]
        ),
        .library(
            name: "SettingsServiceMocks",
            targets: ["SettingsServiceMocks"]
        ),
        .library(
            name: "NotificationServiceInterfaces",
            targets: ["NotificationServiceInterfaces"]
        ),
        .library(
            name: "NotificationService",
            targets: ["NotificationService"]
        ),
        .library(
            name: "NotificationServiceMocks",
            targets: ["NotificationServiceMocks"]
        ),
        .library(
            name: "ContainerService",
            targets: ["ContainerService"]
        ),
        .library(
            name: "LaunchArgumentHandler",
            targets: ["LaunchArgumentHandler"]
        )
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(name: "ContainerService",
                dependencies:
                    [
                        "NotificationService",
                        "PayService",
                        "SettingsService",
                        .product(name: "DomainModels", package: "Core"),
                        .product(name: "Persistance", package: "Core")
                    ]
               ),
        .target(name: "TimerServiceInterfaces",
                dependencies:
                    [
                        .product(
                            name: "DomainModels",
                            package: "Core"
                        )
                    ]
               ),
        .target(
            name: "TimerService",
            dependencies: [
                .target(name: "TimerServiceInterfaces"),
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "FoundationExtensions",
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
            dependencies: [
                "TimerService",
                "TimerServiceMocks"
            ]
        ),
        .target(
            name: "ChartPeriodServiceInterfaces",
            dependencies:
                [
                    .product(
                        name: "DomainModels",
                        package: "Core"
                    )
                ]
        ),
        .target(
            name: "ChartPeriodService",
            dependencies: [
                .target(name: "ChartPeriodServiceInterfaces"),
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "FoundationExtensions",
                    package: "Core"
                ),
            ]
        ),
        .target(
            name: "ChartPeriodServiceMocks",
            dependencies: [
                .target(name: "ChartPeriodServiceInterfaces")
            ]
        ),
        .testTarget(
            name: "ChartPeriodServiceTests",
            dependencies: [
                "ChartPeriodService",
                .product(
                    name: "XCTestExtensions",
                    package: "Core"
                )
            ]
        ),
        .target(
            name: "PayServiceInterfaces",
            dependencies:
                [
                    .product(
                        name: "DomainModels",
                        package: "Core"
                    )
                ]
        ),
        .target(
            name: "PayService",
            dependencies: [
                .target(name: "PayServiceInterfaces"),
                .target(name: "SettingsServiceInterfaces"),
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "Persistance",
                    package: "Core"
                )
            ]
        ),
        .target(
            name: "PayServiceMocks",
            dependencies: [
                .product(name: "DomainModels", package: "Core"),
                .target(name: "PayServiceInterfaces")
            ]
        ),
        .testTarget(
            name: "PayServiceTests",
            dependencies: [
                "PayService",
                "ChartPeriodService",
                "SettingsService",
                "SettingsServiceMocks",
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product( // needed temp
                    name: "Persistance",
                    package: "Core"
                )
            ]
        ),
        .target(name: "SettingsServiceInterfaces"),
        .target(
            name: "SettingsService",
            dependencies:
                [
                "SettingsServiceInterfaces",
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "UIComponents",
                    package: "Core")
            ]
        ),
        .target(
            name: "SettingsServiceMocks",
            dependencies: [
                "SettingsServiceInterfaces"
            ]
        ),
        .target(
            name: "NotificationServiceInterfaces",
            dependencies: [
                .product(
                    name: "DomainModels",
                    package: "Core"
                )
            ]
        ),
        .target(
            name: "NotificationService",
            dependencies: [
                "NotificationServiceInterfaces",
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
                .product(
                    name: "FoundationExtensions",
                    package: "Core"
                )
            ]
        ),
        .target(
            name: "NotificationServiceMocks",
            dependencies: ["NotificationServiceInterfaces"]
        ),
        .testTarget(
            name: "NotificationServiceTests",
            dependencies: [
                "NotificationService",
                "NotificationServiceMocks"
            ]
        ),
        .target(
            name: "LaunchArgumentHandler",
            dependencies: [
                "SettingsServiceInterfaces",
                .product(
                    name: "DomainModels",
                    package: "Core"
                ),
            ]
        )
    ]
)
