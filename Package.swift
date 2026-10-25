// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isDevelop = true

let package = Package(
    name: "MultipartFormDataParser",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v16),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "MultipartFormDataParser", targets: ["MultipartFormDataParser"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "MultipartFormDataParser"),
        .testTarget(name: "MultipartFormDataParserTests", dependencies: ["MultipartFormDataParser"]),
    ],
    swiftLanguageModes: [.v6]
)

// MARK: - develop
if isDevelop {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.12.0"),
        .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
    ])
    package.targets
        .filter(\.isTest)
        .forEach {
            $0.dependencies.append(contentsOf: [
                .product(
                    name: "APIKit",
                    package: "APIKit",
                    condition: .when(platforms: [.macOS, .macCatalyst, .iOS, .tvOS]),
                ),
                .product(
                    name: "Alamofire",
                    package: "Alamofire",
                    condition: .when(platforms: [.macOS, .macCatalyst, .iOS, .tvOS]),
                )
            ])
        }
    package.targets.forEach {
        if $0.plugins == nil {
            $0.plugins = []
        }
        $0.plugins?.append(.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"))
    }
}

// MARK: - Upcoming feature flags for Swift 6
package.targets.forEach {
    $0.swiftSettings = [
        .existentialAny,
        .internalImportsByDefault,
        .memberImportVisibility,
        .inferIsolatedConformances,
        .nonisolatedNonsendingByDefault,
        .immutableWeakCaptures,
        .defaultIsolation(nil)
    ]
}

// ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
private extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                    // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let internalImportsByDefault: Self = .enableUpcomingFeature("InternalImportsByDefault")                // SE-0409, Swift 6.0,  SwiftPM 6.0+
    static let memberImportVisibility: Self = .enableUpcomingFeature("MemberImportVisibility")                    // SE-0444, Swift 6.1,  SwiftPM 6.1+
    static let inferIsolatedConformances: Self = .enableUpcomingFeature("InferIsolatedConformances")              // SE-0470, Swift 6.2,  SwiftPM 6.2+
    static let nonisolatedNonsendingByDefault: Self = .enableUpcomingFeature("NonisolatedNonsendingByDefault")    // SE-0461, Swift 6.2,  SwiftPM 6.2+
    static let immutableWeakCaptures: Self = .enableUpcomingFeature("ImmutableWeakCaptures")                      // SE-0481, Swift 6.2,  SwiftPM 6.2+
}
