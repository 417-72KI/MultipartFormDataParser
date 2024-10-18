import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import MultipartFormDataParser

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

final class MultipartFormDataParserTests: XCTestCase {
    override class func setUp() {
        stubForUpload()
    }

    override class func tearDown() {
        clearStubs()
    }

    func testRequest() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)
        let request = createRequest(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        let data = try MultipartFormData.parse(from: request)
        XCTAssertEqual(data.element(forName: "genbaNeko")?.data, genbaNeko)
        XCTAssertEqual(data.element(forName: "denwaNeko")?.data, denwaNeko)
        XCTAssertEqual(data.element(forName: "message")?.string, "Hello world!")
    }

    func testSequence() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)
        let request = createRequest(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        let data = try MultipartFormData.parse(from: request)
        XCTAssertEqual(["genbaNeko", "denwaNeko", "message"], data.map(\.name))
        XCTAssertEqual([genbaNeko, denwaNeko, Data("Hello world!".utf8)], data.map(\.data))
    }

    // MARK: Failure
    func testEmptyBody() throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=foobar", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("".utf8)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "HTTP body stream is empty.")
        }
    }

    func testNoContentType() throws {
        let request = URLRequest(url: URL(string: "https://localhost/empty")!)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "No Content-Type")
        }
    }

    func testInvalidContentType() throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("".utf8)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "Invalid Content-Type: application/json")
        }
    }

    func testInvalidBody() throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=foobar", forHTTPHeaderField: "Content-Type")

        // body not contains `CRLF`
        request.httpBody = Data("--foobar".utf8)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "Invalid stream.")
        }

        // body not started with boundary
        request.httpBody = Data("foobar\r\n".utf8)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "Invalid stream.")
        }

        // body not end with `--{boundary}--`
        request.httpBody = Data("--foobar\r\n".utf8)
        XCTAssertThrowsError(try MultipartFormData.parse(from: request)) {
            XCTAssertEqual($0.localizedDescription, "Invalid stream.")
        }
    }

    // MARK: using 3rd-party libraries
    #if canImport(Alamofire)
    func testAlamofire() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)

        let result = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testAlamofireWithConcurrency() async throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadWithAlamoFireConcurrency(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
    #endif

    #if canImport(APIKit)
    func testAPIKit() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)

        try runActivity(named: "request") {
            let request = try requestWithAPIKit(
                genbaNeko: genbaNeko,
                denwaNeko: denwaNeko,
                message: message
            )
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
    #endif

    // MARK: URLSession
    func testURLSessionUploadTask() async throws {
        #if os(Linux)
        // FIXME: There is no way to get body stream with `URLSessionUploadTask`.
        try XCTSkipIf(true, "Stubbing `URLSessionUploadTask` in Linux is not supported.")
        #endif
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadURLSessionUpload(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionDataTask() async throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadURLSessionData(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
}

private extension MultipartFormDataParserTests {
    var genbaNeko: Data? {
        #if canImport(UIKit)
        return UIImage(data: TestResource.genbaNeko)?
            .jpegData(compressionQuality: 1)
        #elseif canImport(Cocoa)
        return NSImage(data: TestResource.genbaNeko)?
            .jpegRepresentation
        #elseif os(Linux)
        return Image(data: TestResource.genbaNeko)?.data
        #else
        return TestResource.genbaNeko
        #endif
    }

    var denwaNeko: Data? {
        #if canImport(UIKit)
        return UIImage(data: TestResource.denwaNeko)?
            .jpegData(compressionQuality: 1)
        #elseif canImport(Cocoa)
        return NSImage(data: TestResource.denwaNeko)?
            .jpegRepresentation
        #elseif os(Linux)
        return Image(data: TestResource.denwaNeko)?.data
        #else
        return TestResource.denwaNeko
        #endif
    }
}
