// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickKey",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "QuickKey", targets: ["QuickKey"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", exact: "1.15.0")
    ],
    targets: [
        .executableTarget(
            name: "QuickKey",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "AppSources/QuickKey"
        )
    ]
)
