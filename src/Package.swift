// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SheklyCSVImporter",
    dependencies: [
        .package(
            url: "https://github.com/yaslab/CSV.swift.git",
            .upToNextMinor(from: "2.3.1")
        )
    ],
    targets: [
        .target(
            name: "SheklyCSVImporter",
            dependencies: ["SheklyCSVImporterCore"]
        ),
        .target(
            name: "SheklyCSVImporterCore",
            dependencies: ["CSV"]
            ),
        .testTarget(
                name: "SheklyCSVImporterTests",
                dependencies: ["SheklyCSVImporterCore", "CSV"]
        )
    ]
)
