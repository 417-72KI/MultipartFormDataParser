import Foundation
import XCTest

#if canImport(Alamofire)
import Alamofire

private let session: Session = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return Session(configuration: configuration)
}()

extension XCTestCase {
    func uploadWithAlamoFire(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> TestEntity? {
        let task = session.upload(
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
            to: "https://localhost/upload",
            interceptor: Interceptor()
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = await withCheckedContinuation { cont in
            task.responseDecodable(of: TestEntity.self, decoder: decoder) {
                cont.resume(returning: $0)
            }
        }
        XCTAssertEqual(response.response?.statusCode, 200, file: file, line: line)
        switch response.result {
        case let .success(entity): return entity
        case let .failure(error): throw error
        }
    }

    func uploadWithAlamoFireConcurrency(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> TestEntity {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await session.upload(
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
            to: "https://localhost/upload",
            interceptor: Interceptor()
        )
        .serializingDecodable(TestEntity.self, decoder: decoder)
        .value
    }
}

private class Interceptor: RequestInterceptor {
    private let lock = NSLock()

    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock(); defer { lock.unlock() }

        if request.retryCount < 3 {
            print("retry: \(request.retryCount)")
            completion(.retry)
        } else {
            completion(.doNotRetry)
        }
    }
}
#endif
