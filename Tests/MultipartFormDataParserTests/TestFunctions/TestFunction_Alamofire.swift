import Foundation
import XCTest

#if canImport(Alamofire)
import Alamofire

extension XCTestCase {
    func uploadWithAlamoFire(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
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
            to: "https://localhost/upload",
            interceptor: Interceptor()
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

private class Interceptor: RequestInterceptor {
    private let lock = NSLock()

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
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
