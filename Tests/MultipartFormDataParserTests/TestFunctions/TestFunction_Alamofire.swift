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
    ) throws -> TestEntity? {
        let exp = expectation(description: "response")
        let task = AF.upload(
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
        )
        var response: AFDataResponse<Any>!
        task.responseJSON {
            response = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval)

        XCTAssertNotNil(response, file: file, line: line)
        XCTAssertEqual(response?.response?.statusCode, 200, file: file, line: line)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TestEntity.self, from: try XCTUnwrap(response?.data))
    }
}
