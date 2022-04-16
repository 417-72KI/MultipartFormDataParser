# MultipartFormDataParser
[![Actions Status](https://github.com/417-72KI/MultipartFormDataParser/workflows/Test/badge.svg)](https://github.com/417-72KI/MultipartFormDataParser/actions)<!-- CocoaPods future support
[![Version](http://img.shields.io/cocoapods/v/MultipartFormDataParser.svg?style=flat)](http://cocoapods.org/pods/MultipartFormDataParser)
[![Platform](http://img.shields.io/cocoapods/p/MultipartFormDataParser.svg?style=flat)](http://cocoapods.org/pods/MultipartFormDataParser)
-->
[![GitHub release](https://img.shields.io/github/release/417-72KI/MultipartFormDataParser/all.svg)](https://github.com/417-72KI/MultipartFormDataParser/releases)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-5.5-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FMultipartFormDataParser%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/417-72KI/MultipartFormDataParser)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FMultipartFormDataParser%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/417-72KI/MultipartFormDataParser)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/417-72KI/MultipartFormDataParser/master/LICENSE)


Testing tool for `multipart/form-data` request in Swift.

When to upload some files via API, we must use `multipart/form-data` for request.
`multipart/form-data` is defined as [RFC-2388](https://www.ietf.org/rfc/rfc2388.txt)

Most famous networking libraries (e.g. [Alamofire](https://github.com/Alamofire/Alamofire), [APIKit](https://github.com/ishkawa/APIKit)) can implement easily.
However, to test if the created request is as expected is difficult and bothering.

This library provides a parser for `multipart/form-data` request to test it briefly.

```swift
let request: URLRequest = ...
do {
    let data = try MultipartFormData.parse(from: request)
    let genbaNeko = try XCTUnwrap(data.element(forName: "genbaNeko"))
    let message = try XCTUnwrap(data.element(forName: "message"))
    XCTAssertNotNil(Image(data: genbaNeko.data))
    XCTAssertEqual(genbaNeko.mimeType, "image/jpeg")
    XCTAssertEqual(message.string, "Hello world!")
} catch {
    XCTFail(error.localizedDescription)
}
```

Using [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs), we can test a request created by networking libraries easily.
```swift
let expectedGenbaNeko: Data = ...

let condition = isHost("localhost") && isPath("/upload")
stub(condition: condition) { request in
    let errorResponse = { (message: String) -> HTTPStubsResponse in
        .init(
            jsonObject: ["status": 403, "error": message],
            statusCode: 403, 
            headers: ["Content-Type": "application/json"]
        )
    }
    do {
        let data = try MultipartFormData.parse(from: request)
        guard let genbaNeko = data.element(forName: "genbaNeko"),
              genbaNeko.data == expectedGenbaNeko else { return errorResponse("Unexpected genbaNeko") }
        guard let message = data.element(forName: "message"),
              message.string == "Hello world!" else { return errorResponse("Unexpected message: \(message)") }
    } catch {
        return .init(error: error)
    }
    return .init(
        jsonObject: ["status": 200],
        statusCode: 200,
        headers: ["Content-Type": "application/json"]
    )
}
```

## Installation
### Swift Package Manager
#### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/417-72KI/MultipartFormDataParser.git", from: "1.4.3")
]
```
