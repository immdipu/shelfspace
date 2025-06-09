// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShelfSpace",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ShelfSpace",
            targets: ["ShelfSpace"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ShelfSpace",
            dependencies: [],
            path: "Sources"
        ),
    ]
) 