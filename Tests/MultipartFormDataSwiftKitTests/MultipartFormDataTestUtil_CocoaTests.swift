import XCTest
import Alamofire
import OHHTTPStubs
import OHHTTPStubsSwift

import MultipartFormDataSwiftKit

#if canImport(Cocoa)
import Cocoa
final class MultipartFormDataSwiftKit_CocoaTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        let condition = isHost("localhost")
            && isPath("/upload")
        stub(condition: condition, response: uploadTestStubResponse)
    }

    override class func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testAlamofire() throws {
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
}
#endif
