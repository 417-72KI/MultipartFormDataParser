import XCTest
import Alamofire
import OHHTTPStubs
import OHHTTPStubsSwift

#if canImport(Cocoa)
import Cocoa
#endif

#if canImport(UIKit)
import UIKit
#endif

import MultipartFormDataTestUtil

final class MultipartFormDataTestUtilTests: XCTestCase {

    #if canImport(Cocoa)
    func testWithAlamofire_Cocoa() throws {
        let genbaNeko = try XCTUnwrap(NSImage(data: TestResource.genbaNeko))
        let denwaNeko = try XCTUnwrap(NSImage(data: TestResource.denwaNeko))

        let exp = expectation(description: "response")

        AF.upload(
            multipartFormData: { formData in
                if let genbaNeko = genbaNeko.jpegRepresentation {
                    formData.append(genbaNeko, withName: "genbaNeko")
                }
                if let denwaNeko = denwaNeko.jpegRepresentation {
                    formData.append(denwaNeko, withName: "denwaNeko")
                }
            },
            to: "https://localhost/upload"
            ).responseJSON {
                switch $0.result {
                case let .success(data):
                    do {
                        let dic = try XCTUnwrap(data as? [String: Any])
                        let status = try XCTUnwrap(dic["status"] as? Int)
                        XCTAssertEqual(status, 200)
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
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko))
        let exp = expectation(description: "response")

        AF.upload(
            multipartFormData: { formData in
                if let genbaNeko = genbaNeko.jpegData(compressionQuality: 1) {
                    formData.append(genbaNeko, withName: "genbaNeko")
                }
                if let denwaNeko = denwaNeko.jpegData(compressionQuality: 1) {
                    formData.append(denwaNeko, withName: "denwaNeko")
                }
            },
            to: "https://localhost/upload"
            ).responseJSON {
                switch $0.result {
                case let .success(data):
                    do {
                        let dic = try XCTUnwrap(data as? [String: Any])
                        let status = try XCTUnwrap(dic["status"] as? Int)
                        XCTAssertEqual(status, 200)
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
            guard let stream = request.httpBodyStream else {
                return .init(jsonObject: [], statusCode: 403, headers: ["Content-Type": "application/json"])
            }

            return .init(jsonObject: ["status": 200], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
    }

    override class func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
}
