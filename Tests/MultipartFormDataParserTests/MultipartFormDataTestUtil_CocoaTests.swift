import XCTest
import MultipartFormDataParser

#if canImport(Cocoa)
import Cocoa

final class MultipartFormDataParser_CocoaTests: XCTestCase {

    override class func setUp() {
        stubForUpload()
    }

    override class func tearDown() {
        clearStubs()
    }

    func testAlamofire() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let data = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        let dic = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
        XCTAssertEqual(dic["status"] as? Int, 200)
        XCTAssertNil(dic["error"])
    }

    func testAPIKit() {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let data = try XCTUnwrap(uploadWithAPIKit(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        let dic = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
        XCTAssertEqual(dic["status"] as? Int, 200)
        XCTAssertNil(dic["error"])
    }
}
#endif
