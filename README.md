# MultipartFormDataParser
[![Actions Status](https://github.com/417-72KI/MultipartFormDataParser/workflows/Test/badge.svg)](https://github.com/417-72KI/MultipartFormDataParser/actions)<!-- CocoaPods future support
[![Version](http://img.shields.io/cocoapods/v/MultipartFormDataParser.svg?style=flat)](http://cocoapods.org/pods/MultipartFormDataParser)
[![Platform](http://img.shields.io/cocoapods/p/MultipartFormDataParser.svg?style=flat)](http://cocoapods.org/pods/MultipartFormDataParser)
-->
[![GitHub release](https://img.shields.io/github/release/417-72KI/MultipartFormDataParser/all.svg)](https://github.com/417-72KI/MultipartFormDataParser/releases)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-4.2.0-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/417-72KI/MultipartFormDataParser/master/LICENSE)


Testing tool for `multipart/form-data` in Swift

## Usage 

### example
```swift
let request: URLRequest = ...
do {
    let data = try MultipartFormData.parse(from: request)
    let genbaNeko = try XCTUnwrap(data.element(forName: "genbaNeko"))
    let denwaNeko = try XCTUnwrap(data.element(forName: "denwaNeko"))
    let message = try XCTUnwrap(data.element(forName: "message"))
    XCTAssertNotNil(Image(data: genbaNeko.data))
    XCTAssertEqual(genbaNeko.mimeType, "image/jpeg")
    XCTAssertNotNil(Image(data: denwaNeko.data))
    XCTAssertEqual(denwaNeko.mimeType, "image/jpeg")
    XCTAssertEqual(message.string, "Hello world!")
} catch {
    XCTFail(error.localizedDescription)
}
```
