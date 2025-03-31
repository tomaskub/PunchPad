// swift-tools-version: 6.0
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
        )
//        .library(
//            name: "Persistance",
//            targets: ["Persistance"]
//        )
    ],
    targets: [
        .target(name: "UIComponents",
                dependencies: [
                    .target(name: "DomainModels"),
                    .target(name: "FoundationExtensions")
                ]
               ),
        .target(name: "DomainModels"),
        .target(name: "FoundationExtensions"),

//        .target(name: "Persistance"),
//        .testTarget(
//            name: "PeristanceTests",
//            dependencies: ["Core"]
//        )
    ]
)
