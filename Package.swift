// swift-tools-version:5.8
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
            targets: ["MultipartFormDataParser"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MultipartFormDataParser",
            dependencies: []
        ),
        .testTarget(
            name: "MultipartFormDataParserTests",
            dependencies: ["MultipartFormDataParser"]
        ),
    ]
)

// MARK: - develop
if !isRelease {
    if !isLinux {
        package.dependencies.append(contentsOf: [
            .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
            .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
            .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        ])
        package.targets
            .filter(\.isTest)
            .forEach {
                $0.dependencies.append(contentsOf: [
                    "Alamofire",
                    "APIKit",
                    "Moya"
                ])
            }
    }
}
