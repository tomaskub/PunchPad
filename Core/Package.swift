// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    
    name: "Core",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]
        ),
        .library(
            name: "DomainModels",
            targets: ["DomainModels"]
        ),
        .library(
            name: "FoundationExtensions",
            targets: ["FoundationExtensions"]
        ),
        .library(
            name: "XCTestExtensions",
            targets: ["XCTestExtensions"]
        ),
        .library(
            name: "Persistance",
            targets: ["Persistance"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/ThemeKit")
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                .target(name: "DomainModels"),
                .target(name: "FoundationExtensions"),
                .product(name: "ThemeKit", package: "ThemeKit")
            ]
        ),
        .target(name: "DomainModels"),
        .target(name: "FoundationExtensions"),
        .target(name: "XCTestExtensions"),
        .target(
            name: "Persistance",
            dependencies: [
                .target(name: "DomainModels")
            ]
        )
    ]
)
