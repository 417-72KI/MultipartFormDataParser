import XCTest
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
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let request = createRequest(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        let data = try MultipartFormData.parse(from: request)
        XCTAssertEqual(data.element(forName: "genbaNeko")?.data, genbaNeko)
        XCTAssertEqual(data.element(forName: "denwaNeko")?.data, denwaNeko)
        XCTAssertEqual(data.element(forName: "message")?.string, "Hello world!")
    }

    #if canImport(Alamofire)
    func testAlamofire() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    #if compiler(>=5.6) && canImport(_Concurrency)
    @available(macCatalyst 13, iOS 13, tvOS 13, *)
    func testAlamofireWithConcurrency() async throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try await uploadWithAlamoFireConcurrency(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
    #endif
    #endif

    #if canImport(APIKit)
    func testAPIKit() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
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
    #endif

    #if canImport(Moya)
    func testMoya() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let result = try XCTUnwrap(uploadWithMoya(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }
    #endif

    func testURLSessionUploadTask() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionUploadTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        XCTAssertEqual(result.status, 200)
        XCTAssertNil(result.error)
    }

    func testURLSessionDataTask() throws {
        let genbaNeko = try XCTUnwrap(genbaNeko)
        let denwaNeko = try XCTUnwrap(denwaNeko)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))
        let result = try XCTUnwrap(uploadURLSessionDataTask(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
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
        #else
        fatalError()
        #endif
    }

    var denwaNeko: Data? {
        #if canImport(UIKit)
        return UIImage(data: TestResource.denwaNeko)?
            .jpegData(compressionQuality: 1)
        #elseif canImport(Cocoa)
        return NSImage(data: TestResource.denwaNeko)?
            .jpegRepresentation
        #else
        fatalError()
        #endif
    }
}