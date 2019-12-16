# MultipartFormDataParser

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
