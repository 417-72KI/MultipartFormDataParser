import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

private let session: URLSession = {
    #if canImport(OHHTTPStubs)
    return .shared
    #else
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: configuration)
    #endif
}()

extension XCTestCase {
    func uploadURLSessionData(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> TestEntity {
        let request = createRequest(genbaNeko: genbaNeko, denwaNeko: denwaNeko, message: message)
        do {
            let (data, _) = try await session.data(for: request)
            return try JSONDecoder().decode(TestEntity.self, from: data)
        } catch {
            guard retryCount > 0 else { throw error }
            return try await uploadURLSessionData(genbaNeko: genbaNeko,
                                                  denwaNeko: denwaNeko,
                                                  message: message,
                                                  retryCount: retryCount - 1,
                                                  file: file,
                                                  line: line)
        }
    }

    func uploadURLSessionUpload(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        retryCount: UInt = 3,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> TestEntity {
        let boundary = "YoWatanabe0417"
        var request = URLRequest(url: URL(string: "https://localhost/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let requestBody = createBody(boundary: boundary,
                                     genbaNeko: genbaNeko,
                                     denwaNeko: denwaNeko,
                                     message: message)
        do {
            let (data, _) = try await session.upload(for: request, from: requestBody)
            return try JSONDecoder().decode(TestEntity.self, from: data)
        } catch {
            guard retryCount > 0 else { throw error }
            return try await uploadURLSessionUpload(genbaNeko: genbaNeko,
                                                    denwaNeko: denwaNeko,
                                                    message: message,
                                                    retryCount: retryCount - 1,
                                                    file: file,
                                                    line: line)
        }
    }
}

extension XCTestCase {
    func createRequest(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) -> URLRequest {
        let boundary = "YoWatanabe0417"
        var request = URLRequest(url: URL(string: "https://localhost/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(
            boundary: boundary,
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            message: message
        )
        return request
    }
}

private func createBody(boundary: String,
                        genbaNeko: Data,
                        denwaNeko: Data,
                        message: Data) -> Data {
    [
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"genbaNeko\"; filename=\"genbaNeko\"\r\n".utf8),
        Data("Content-Type: image/jpeg\r\n".utf8),
        Data("\r\n".utf8),
        genbaNeko,
        Data("\r\n".utf8),
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"denwaNeko\"; filename=\"denwaNeko\"\r\n".utf8),
        Data("Content-Type: image/jpeg\r\n".utf8),
        Data("\r\n".utf8),
        denwaNeko,
        Data("\r\n".utf8),
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"message\"\r\n".utf8),
        Data("\r\n".utf8),
        message,
        Data("\r\n".utf8),
        Data("--\(boundary)--\r\n".utf8),
    ].reduce(Data(), +)
}
