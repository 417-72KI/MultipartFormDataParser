import APIKit
import Foundation
import XCTest

extension XCTestCase {
    func uploadWithAPIKit(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TestEntity? {
        let exp = expectation(description: "response")
        let request = TestRequest(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            message: message,
            file: file,
            line: line
        )
        var result: Result<TestRequest.Response, SessionTaskError>!
        Session.shared.send(request, callbackQueue: nil) {
            result = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: timeoutInterval)
        return try result.get()
    }
}

private struct TestRequest: APIKit.Request {
    typealias Response = TestEntity

    var baseURL: URL { URL(string: "https://localhost")! }
    var path: String { "/upload" }
    var method: APIKit.HTTPMethod { .post }

    var genbaNeko: Data
    var denwaNeko: Data
    var message: Data

    var file: StaticString
    var line: UInt

    var bodyParameters: BodyParameters? {
        let parts: [MultipartFormDataBodyParameters.Part] = [
            .init(
                data: genbaNeko,
                name: "genbaNeko",
                mimeType: "genbaNeko.jpeg",
                fileName: "image/jpeg"
            ),
            .init(
                data: denwaNeko,
                name: "denwaNeko",
                mimeType: "denwaNeko.jpeg",
                fileName: "image/jpeg"
            ),
            .init(data: message, name: "message")
        ]
        return MultipartFormDataBodyParameters(parts: parts)
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        XCTAssertEqual(urlResponse.statusCode, 200, file: file, line: line)
        switch object {
        case let data as Data:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Response.self, from: data)
        case let dic as [String: Any]:
            guard let status = dic["status"] as? Int else {
                throw ResponseError.unexpectedObject(object)
            }
            return Response(status: status, error: dic["error"] as? String)
        default:
            throw ResponseError.unexpectedObject(object)
        }
    }
}
