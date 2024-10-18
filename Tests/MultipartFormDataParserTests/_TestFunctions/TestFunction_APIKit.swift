import Foundation
import XCTest

#if canImport(APIKit)
import APIKit

private let session: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [StubURLProtocol.self]
    let adapter = URLSessionAdapter(configuration: configuration)
    return Session(adapter: adapter)
}()

extension XCTestCase {
    func requestWithAPIKit(
        genbaNeko: Data,
        denwaNeko: Data,
        pdf: Data,
        message: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URLRequest {
        try TestRequest(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message,
            file: file,
            line: line
        ).buildURLRequest()
    }

    func uploadWithAPIKit(
        genbaNeko: Data,
        denwaNeko: Data,
        pdf: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> TestEntity {
        let request = TestRequest(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message,
            file: file,
            line: line
        )
        let result = await withCheckedContinuation { cont in
            session.send(request, callbackQueue: nil) {
                cont.resume(returning: $0)
            }
        }

        switch result {
        case let .success(response):
            return response
        case let .failure(error):
            if retryCount > 0 {
                print("retry: \(retryCount)")
                return try await uploadWithAPIKit(
                    genbaNeko: genbaNeko,
                    denwaNeko: denwaNeko,
                    pdf: pdf,
                    message: message,
                    retryCount: retryCount - 1,
                    file: file,
                    line: line
                )
            }
            throw error
        }
    }
}

private struct TestRequest: APIKit.Request {
    typealias Response = TestEntity

    var baseURL: URL { URL(string: "https://localhost")! }
    var path: String { "/upload" }
    var method: APIKit.HTTPMethod { .post }

    var genbaNeko: Data
    var denwaNeko: Data
    var pdf: Data
    var message: Data

    var file: StaticString
    var line: UInt

    var bodyParameters: (any BodyParameters)? {
        let parts: [MultipartFormDataBodyParameters.Part] = [
            .init(
                data: genbaNeko,
                name: "genbaNeko",
                mimeType: "image/jpeg",
                fileName: "genbaNeko.jpeg"
            ),
            .init(
                data: denwaNeko,
                name: "denwaNeko",
                mimeType: "image/jpeg",
                fileName: "denwaNeko.jpeg"
            ),
            .init(
                data: pdf,
                name: "pdf",
                mimeType: "application/pdf",
                fileName: "example.pdf"
            ),
            .init(data: message, name: "message"),
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
#endif
