import Foundation
import XCTest

extension XCTestCase {
    func uploadURLSessionUploadTask(
        genbaNeko: Data,
        denwaNeko: Data,
        message: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TestEntity? {
        let exp = expectation(description: "response")

        let boundary = "YoWatanabe0417"
        var request = URLRequest(url: URL(string: "https://localhost/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = createBody(boundary: boundary,
                              genbaNeko: genbaNeko,
                              denwaNeko: denwaNeko,
                              message: message)
        var entity: TestEntity!
        URLSession.shared.uploadTask(with: request, from: data) { data, _, _ in
            defer { exp.fulfill() }
            entity = try? data.flatMap { try JSONDecoder().decode(TestEntity.self, from: $0) }
        }.resume()

        wait(for: [exp], timeout: 10)
        return entity
    }
}

private func createBody(boundary: String,
                        genbaNeko: Data,
                        denwaNeko: Data,
                        message: Data) -> Data {
    var data = "--\(boundary)\r\n".data(using: .utf8)!
    data += "Content-Disposition: form-data; name=\"genbaNeko\"; filename=\"genbaNeko\"\r\n".data(using: .utf8)!
    data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
    data += "\r\n".data(using: .utf8)!
    data += genbaNeko
    data += "\r\n".data(using: .utf8)!
    data += "--\(boundary)\r\n".data(using: .utf8)!
    data += "Content-Disposition: form-data; name=\"denwaNeko\"; filename=\"denwaNeko\"\r\n".data(using: .utf8)!
    data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
    data += "\r\n".data(using: .utf8)!
    data += denwaNeko
    data += "\r\n".data(using: .utf8)!
    data += "--\(boundary)\r\n".data(using: .utf8)!
    data += "Content-Disposition: form-data; name=\"message\"\r\n".data(using: .utf8)!
    data += "\r\n".data(using: .utf8)!
    data += message
    data += "\r\n".data(using: .utf8)!
    data += "--\(boundary)--\r\n".data(using: .utf8)!
    return data
}
