import XCTest
import Alamofire
import OHHTTPStubs
import OHHTTPStubsSwift

import MultipartFormDataParser

#if canImport(UIKit)
import UIKit

final class MultipartFormDataParser_UIKitTests: XCTestCase {

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
        let genbaNeko = try XCTUnwrap(UIImage(data: TestResource.genbaNeko)?.jpegData(compressionQuality: 1))
        let denwaNeko = try XCTUnwrap(UIImage(data: TestResource.denwaNeko)?.jpegData(compressionQuality: 1))
        let message = try XCTUnwrap("Hello world!".data(using: .utf8))

        let data = try XCTUnwrap(uploadWithAlamoFire(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message))
        let dic = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
        XCTAssertEqual(dic["status"] as? Int, 200)
        XCTAssertNil(dic["error"])
    }
}
#endif
