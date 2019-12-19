import Alamofire
import Foundation
import XCTest

extension XCTestCase {
    func uploadWithAlamoFire(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data? {
        let exp = expectation(description: "response")
        let request = AF.upload(
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
            ).responseJSON { _ in exp.fulfill() }
        wait(for: [exp], timeout: 10)
        let response = try XCTUnwrap(request.response, file: file, line: line)
        XCTAssertEqual(response.statusCode, 200, file: file, line: line)
        return request.data
    }
}
