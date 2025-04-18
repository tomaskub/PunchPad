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
        )
    ],
    dependencies: [
        .package(path: "../Services"),
        .package(path: "../Packages/ThemeKit")
    ],
    targets: [
        .target(
            name: "Onboarding",
        dependencies: [
            .product(name: "NotificationService", package: "Services"),
            .product(name: "SettingsService", package: "Services"),
            .product(name: "ThemeKit", package: "ThemeKit")
            ]
        )
    ]
)
