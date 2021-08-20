import Foundation
import XCTest

extension XCTestCase {
    func uploadURLSessionDataTask(
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
        request.httpBody = createBody(boundary: boundary,
                              genbaNeko: genbaNeko,
                              denwaNeko: denwaNeko,
                              message: message)
        var responseData: Data!
        URLSession.shared.dataTask(with: request) { data, _, _ in
            responseData = data
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: timeoutInterval)
        return try JSONDecoder().decode(TestEntity.self, from: (try XCTUnwrap(responseData)))
    }

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
        var responseData: Data!
        URLSession.shared.uploadTask(with: request, from: data) { data, _, _ in
            responseData = data
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: timeoutInterval)
        return try JSONDecoder().decode(TestEntity.self, from: (try XCTUnwrap(responseData)))
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
