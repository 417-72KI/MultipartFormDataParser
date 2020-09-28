import XCTest
import MultipartFormDataParser

#if canImport(UIKit)
import UIKit

final class MultipartFormDataParser_UIKitTests: XCTestCase {

    override class func setUp() {
        stubForUpload()
    }

    override class func tearDown() {
        clearStubs()
    }

    func testAlamofire() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testAPIKit() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithAPIKit(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testMoya() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithMoya(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionUploadTask() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionUploadTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionDataTask() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionDataTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
}
#endif
