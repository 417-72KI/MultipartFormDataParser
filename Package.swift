// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isRelease = true

let testDependencies: [Package.Dependency] = isRelease
? []
: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    // .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
    .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.3.0"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
]
let testTargetDependencies: [Target.Dependency] = isRelease
? []
: [
    "Alamofire",
    "APIKit",
    "Moya",
    // .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
]

let package = Package(
    name: "MultipartFormDataParser",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "MultipartFormDataParser",
            targets: ["MultipartFormDataParser"]),
    ],
    dependencies: testDependencies,
    targets: [
        .target(
            name: "MultipartFormDataParser",
            dependencies: []
        ),
        .testTarget(
            name: "MultipartFormDataParserTests",
            dependencies: [
                "MultipartFormDataParser",
            ] + testTargetDependencies
        ),
    ]
)
