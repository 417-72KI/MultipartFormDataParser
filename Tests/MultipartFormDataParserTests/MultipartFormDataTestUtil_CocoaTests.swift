import XCTest
import MultipartFormDataParser

#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa

final class MultipartFormDataParser_CocoaTests: XCTestCase {

    override func setUp() {
        stubForUpload()
    }

    override func tearDown() {
        clearStubs()
    }

    func testRequest() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let request = createRequest(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        let data = try MultipartFormData.parse(from: request)
        XCTAssertEqual(data.element(forName: "genbaNeko")?.data, genbaNeko)
        XCTAssertEqual(data.element(forName: "denwaNeko")?.data, denwaNeko)
        XCTAssertEqual(data.element(forName: "message")?.string, "Hello world!")
    }

    func testAlamofire() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testAPIKit() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        try runActivity(named: "request") {
            let request = try requestWithAPIKit(genbaNeko: genbaNeko,
                                                denwaNeko: denwaNeko,
                                                message: message)
            let data = try MultipartFormData.parse(from: request)
            XCTAssertEqual(data.element(forName: "genbaNeko")?.data, genbaNeko)
            XCTAssertEqual(data.element(forName: "denwaNeko")?.data, denwaNeko)
            XCTAssertEqual(data.element(forName: "message")?.string, "Hello world!")
        }

        try runActivity(named: "stub") {
            let result = try XCTUnwrap(uploadWithAPIKit(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
            XCTAssertEqual(result.status, 200)
            XCTAssertNil(result.error)
        }
    }

    func testMoya() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithMoya(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionDataTask() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionDataTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionUploadTask() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionUploadTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
}
#endif
