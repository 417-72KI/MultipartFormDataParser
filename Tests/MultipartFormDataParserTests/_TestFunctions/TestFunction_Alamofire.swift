import Foundation
import Testing

#if canImport(Alamofire)
import Alamofire

func session(configuration: URLSessionConfiguration) -> Session {
    Session(configuration: configuration)
}

func uploadWithAlamoFire(
    _ session: Session,
    genbaNeko: Data,
    denwaNeko: Data,
    message: Data,
    retryCount: UInt = 3,
    sourceLocation: SourceLocation = #_sourceLocation
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

private final class Interceptor: RequestInterceptor {
    private let lock = NSLock()

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: (RetryResult) -> Void
    ) {
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
