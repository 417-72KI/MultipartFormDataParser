import Foundation
import Moya
import XCTest

extension XCTestCase {
    func uploadWithMoya(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TestEntity? {
        let exp = expectation(description: "response")

        let target = TestTarget(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            message: message,
            file: file,
            line: line
        )
        var result: Result<Response, MoyaError>!
        MoyaProvider().request(target) {
            result = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval)

        XCTAssertNotNil(result)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TestEntity.self, from: try XCTUnwrap(try result.get().data))
    }
}

private struct TestTarget: TargetType {
    var genbaNeko: Data
    var denwaNeko: Data
    var message: Data

    var file: StaticString
    var line: UInt

    var baseURL: URL { URL(string: "https://localhost")! }
    var path: String { "/upload" }
    var method: Moya.Method { .post }
    var headers: [String : String]? { [:] }
}

extension TestTarget {
    var task: Task {
        let formData: [Moya.MultipartFormData] = [
            Moya.MultipartFormData(provider: .data(genbaNeko), name: "genbaNeko", fileName: "genbaNeko.jpeg", mimeType: "image/jpeg"),
            Moya.MultipartFormData(provider: .data(denwaNeko), name: "denwaNeko", fileName: "denwaNeko.jpeg", mimeType: "image/jpeg"),
            Moya.MultipartFormData(provider: .data(message), name: "message")
        ]
        return .uploadMultipart(formData)
    }
    var validationType: ValidationType { .successCodes }
    var sampleData: Data { .init() }
}
