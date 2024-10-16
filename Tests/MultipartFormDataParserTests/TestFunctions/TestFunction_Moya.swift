import Foundation
import XCTest

#if canImport(Moya)
import Moya

private let provider: MoyaProvider<TestTarget> = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return MoyaProvider(session: Session(configuration: configuration))
}()

extension XCTestCase {
    @MainActor
    func uploadWithMoya(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #filePath,
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
        provider.request(target) {
            result = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: timeoutInterval)

        XCTAssertNotNil(result)

        switch result! {
        case let .success(response):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(TestEntity.self, from: response.data)
        case let .failure(error):
            if retryCount > 0 {
                print("retry: \(retryCount)")
                return try uploadWithMoya(genbaNeko: genbaNeko,
                                          denwaNeko: denwaNeko,
                                          message: message,
                                          retryCount: retryCount - 1,
                                          file: file,
                                          line: line)
            } else {
                throw error
            }
        }
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
#endif
