// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultipartFormDataParser",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MultipartFormDataParser",
            targets: ["MultipartFormDataParser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.4")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.1.0")),
        .package(url: "https://github.com/ishkawa/APIKit.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.1"))
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MultipartFormDataParser",
            dependencies: []),
        .testTarget(
            name: "MultipartFormDataParserTests",
            dependencies: [
                "MultipartFormDataParser",
                "Alamofire",
                "APIKit",
                "Moya",
                "OHHTTPStubsSwift"
            ]
        ),
    ]
)
