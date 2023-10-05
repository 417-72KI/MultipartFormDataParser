// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isRelease = true
let isLinux: Bool = {
#if os(Linux)
    return true
#else
    return false
#endif
}()

let testDependencies: [Package.Dependency] = isRelease
? []
: (isLinux ? [] : [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
    .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
])
let testTargetDependencies: [Target.Dependency] = isRelease
? []
: [
] + (isLinux ? [] : [
    "Alamofire",
    "APIKit",
    "Moya",
])

let package = Package(
    name: "MultipartFormDataParser",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15)
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
