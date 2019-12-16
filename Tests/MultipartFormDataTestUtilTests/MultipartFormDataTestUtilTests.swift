import XCTest
import Alamofire
import OHHTTPStubs
import OHHTTPStubsSwift

#if canImport(Cocoa)
import Cocoa
typealias Image = NSImage
#endif

#if canImport(UIKit)
import UIKit
typealias Image = UIImage
#endif

import MultipartFormDataTestUtil

final class MultipartFormDataTestUtilTests: XCTestCase {

    #if canImport(Cocoa)
    func testWithAlamofire_Cocoa() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko)?.jpegRepresentation)
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko)?.jpegRepresentation)
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let exp = expectation(description: "response")

        AF.upload(
            multipartFormData: { formData in
                formData.append(
                    genbaNeko,
                    withName: "genbaNeko",
                    fileName: "genbaNeko.jpeg",
                    mimeType: "image/jpeg"
                )
                formData.append(
                    denwaNeko,
                    withName: "denwaNeko",
                    fileName: "denwaNeko.jpeg",
                    mimeType: "image/jpeg"
                )
                formData.append(message, withName: "message")
            },
            to: "https://localhost/upload"
            ).responseJSON {
                switch $0.result {
                case let .success(data):
                    do {
                        let dic = try XCTUnwrap(data as? [String: Any])
                        let status = try XCTUnwrap(dic["status"] as? Int)
                        XCTAssertEqual(status, 200)
                        XCTAssertNil(dic["error"])
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }
    #endif

    #if canImport(UIKit)
    func testWithAlamofire_UIKit() throws {
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let exp = expectation(description: "response")

        AF.upload(
            multipartFormData: { formData in
                formData.append(
                    genbaNeko,
                    withName: "genbaNeko",
                    fileName: "genbaNeko.jpeg",
                    mimeType: "image/jpeg"
                )
                formData.append(
                    denwaNeko,
                    withName: "denwaNeko",
                    fileName: "denwaNeko.jpeg",
                    mimeType: "image/jpeg"
                )
                formData.append(message, withName: "message")
            },
            to: "https://localhost/upload"
            ).responseJSON {
                switch $0.result {
                case let .success(data):
                    do {
                        let dic = try XCTUnwrap(data as? [String: Any])
                        let status = try XCTUnwrap(dic["status"] as? Int)
                        XCTAssertEqual(status, 200)
                        XCTAssertNil(dic["error"])
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }
    #endif

    override class func setUp() {
        super.setUp()
        let condition = isHost("localhost")
            && isPath("/upload")
        stub(condition: condition) { request in
            let errorResponse = { (message: String) -> OHHTTPStubsResponse in
                .init(jsonObject: ["status": 403, "error": message], statusCode: 403, headers: ["Content-Type": "application/json"])
            }
            do {
                let data = try MultipartFormData.parse(from: request)
                guard let genbaNeko = data.element(forName: "genbaNeko") else { return errorResponse("genbaNeko") }
                guard let denwaNeko = data.element(forName: "denwaNeko") else { return errorResponse("denwaNeko") }
                guard let message = data.element(forName: "message") else { return errorResponse("message") }
                guard let _ = Image(data: genbaNeko.data) else { return errorResponse("Unexpected genbaNeko") }
                // try genbaNeko.data.write(to: URL(fileURLWithPath: ("~/work/genbaNeko.jpg" as NSString).expandingTildeInPath), options: .atomicWrite)
                guard let _ = Image(data: denwaNeko.data) else { return errorResponse("Unexpected denwaNeko") }
                // try denwaNeko.data.write(to: URL(fileURLWithPath: ("~/work/denwaNeko.jpg" as NSString).expandingTildeInPath), options: .atomicWrite)
                guard message.string == "Hello world!" else { return errorResponse("Unexpected message: \(message)") }
            } catch {
                return .init(error: error)
            }
            return .init(
                jsonObject: ["status": 200],
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    override class func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
}

