// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultipartFormDataSwiftKit",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MultipartFormDataSwiftKit",
            targets: ["MultipartFormDataSwiftKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0-rc.3")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", Package.Dependency.Requirement.branch("feature/spm-support"))
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MultipartFormDataSwiftKit",
            dependencies: []),
        .testTarget(
            name: "MultipartFormDataSwiftKitTests",
            dependencies: [
                "MultipartFormDataSwiftKit",
                "Alamofire",
                "OHHTTPStubsSwift"
            ]
        ),
    ]
)
