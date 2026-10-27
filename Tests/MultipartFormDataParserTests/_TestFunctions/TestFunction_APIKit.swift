import Foundation
import Testing

#if canImport(APIKit)
import APIKit

func session(configuration: URLSessionConfiguration) -> Session {
    let adapter = URLSessionAdapter(configuration: configuration)
    return Session(adapter: adapter)
}

func requestWithAPIKit(
    genbaNeko: Data,
    denwaNeko: Data,
    pdf: Data,
    message: Data,
    sourceLocation: SourceLocation = #_sourceLocation
) -> TestRequest {
    TestRequest(
        genbaNeko: genbaNeko,
        denwaNeko: denwaNeko,
        pdf: pdf,
        message: message,
        sourceLocation: sourceLocation
    )
}

@concurrent
func uploadWithAPIKit<R: Request>(
    _ session: Session,
    request: R,
    retryCount: UInt = 3,
    sourceLocation: SourceLocation = #_sourceLocation
) async throws -> R.Response {
    do {
        return try await session.response(for: request)
    } catch {
        if retryCount > 0 {
            print("retry: \(retryCount)")
            return try await uploadWithAPIKit(
                session,
                request: request,
                retryCount: retryCount - 1,
                sourceLocation: sourceLocation
            )
        }
        throw error
    }
}

struct TestRequest: APIKit.Request {
    typealias Response = TestEntity

    var baseURL: URL { URL(string: "https://localhost")! }
    var path: String { "/upload" }
    var method: APIKit.HTTPMethod { .post }

    var genbaNeko: Data
    var denwaNeko: Data
    var pdf: Data
    var message: Data

    var sourceLocation: SourceLocation

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
        #expect(urlResponse.statusCode == 200, sourceLocation: sourceLocation)
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
