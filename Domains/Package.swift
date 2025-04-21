// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domains",
    platforms: [.iOS("16.6")],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        ),
        .library(
            name: "Settings",
            targets: ["Settings"]
        ),
        .library(
            name: "Statistics",
            targets: ["Statistics"]
        ),
        .library(
            name: "History",
            targets: ["History"]
        ),
        .library(
            name: "Home",
            targets: ["Home"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Services"),
        .package(path: "../Packages/ThemeKit"),
        .package(path: "../Packages/NavigationKit"),
        .package(path: "../Packages/TabViewKit"),

    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
            .product(name: "NotificationService", package: "Services"),
            .product(name: "SettingsService", package: "Services"),
            .product(name: "ThemeKit", package: "ThemeKit")
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "DomainModels", package: "Core"),
                .product(name: "UIComponents", package: "Core"),
                .product(name: "Persistance", package: "Core"),
                .product(name: "NotificationService", package: "Services"),
                .product(name: "NotificationServiceInterfaces", package: "Services"),
                .product(name: "SettingsService", package: "Services"),
                .product(name: "NavigationKit", package: "NavigationKit"),
                .product(name: "ThemeKit", package: "ThemeKit")
            ]
        ),
        .target(
            name: "Statistics",
            dependencies: [
                .product(name: "DomainModels", package: "Core"),
                .product(name: "FoundationExtensions", package: "Core"),
                .product(name: "UIComponents", package: "Core"),
                .product(name: "Persistance", package: "Core"),
                .product(name: "SettingsService", package: "Services"),
                .product(name: "ChartPeriodService", package: "Services"),
                .product(name: "PayService", package: "Services"),
                .product(name: "ThemeKit", package: "ThemeKit")
            ]
        ),
        .testTarget(name: "StatisticsTests",
                    dependencies: [
                        "Statistics",
                        .product(name: "ContainerService", package: "Services"),
                        .product(name: "UIComponents", package: "Core"),
                        .product(name: "XCTestExtensions", package: "Core")
                    ]
                   ),
        .target(
            name: "History",
            dependencies: [ 
                .product(name: "ChartPeriodService", package: "Services"),
                .product(name: "ContainerService", package: "Services"),
                .product(name: "DomainModels", package: "Core"),
                .product(name: "FoundationExtensions", package: "Core"),
                .product(name: "PayService", package: "Services"),
                .product(name: "Persistance", package: "Core"),
                .product(name: "SettingsService", package: "Services"),
                .product(name: "ThemeKit", package: "ThemeKit"),
                .product(name: "UIComponents", package: "Core")
            ]
        ),
        .testTarget(name: "HistoryTests",
                    dependencies: [
                        "History",
                        .product(name: "XCTestExtensions", package: "Core")
                    ]
                   ),
        .target(name: "Home",
                dependencies: [
                    .product(name: "ContainerService", package: "Services"),
                    .product(name: "DomainModels", package: "Core"),
                    .product(name: "Persistance", package: "Core"),
                    .product(name: "NavigationKit", package: "NavigationKit"),
                    .product(name: "ThemeKit", package: "ThemeKit"),
                    .product(name: "TabViewKit", package: "TabViewKit"),
                    .product(name: "NotificationService", package: "Services"),
                    .product(name: "NotificationServiceInterfaces", package: "Services"),
                    .product(name: "TimerService", package: "Services"),
                    .product(name: "PayService", package: "Services"),
                    .product(name: "SettingsService", package: "Services"),
                ]
               ),
        .testTarget(name: "HomeTests",
                    dependencies: [
                        "Home",
                        .product(name: "DomainModels", package: "Core"),
                        .product(name: "Persistance", package: "Core"),
                        .product(name: "NotificationServiceMocks", package: "Services"),
                        .product(name: "TimerServiceMocks", package: "Services"),
                        .product(name: "PayService", package: "Services"),
                        .product(name: "SettingsService", package: "Services"),
                        .product(name: "ContainerService", package: "Services"),
                    ]
                   )
    ]
)
