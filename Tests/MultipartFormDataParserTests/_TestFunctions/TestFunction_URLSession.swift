import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func uploadURLSessionData(
    _ session: URLSession,
    genbaNeko: Data,
    denwaNeko: Data,
    pdf: Data,
    message: Data,
    retryCount: UInt = 3,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> TestEntity {
    let request = createRequest(
        genbaNeko: genbaNeko,
        denwaNeko: denwaNeko,
        pdf: pdf,
        message: message
    )
    do {
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(TestEntity.self, from: data)
    } catch {
        guard retryCount > 0 else { throw error }
        return try await uploadURLSessionData(
            session,
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message,
            retryCount: retryCount - 1,
            file: file,
            line: line
        )
    }
}

func uploadURLSessionUpload(
    _ session: URLSession,
    genbaNeko: Data,
    denwaNeko: Data,
    pdf: Data,
    message: Data,
    retryCount: UInt = 3,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> TestEntity {
    let boundary = "YoWatanabe0417"
    var request = URLRequest(url: URL(string: "https://localhost/upload")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let requestBody = createBody(
        boundary: boundary,
        genbaNeko: genbaNeko,
        denwaNeko: denwaNeko,
        pdf: pdf,
        message: message
    )
    do {
        let (data, _) = try await session.upload(for: request, from: requestBody)
        return try JSONDecoder().decode(TestEntity.self, from: data)
    } catch {
        guard retryCount > 0 else { throw error }
        return try await uploadURLSessionUpload(
            session,
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message,
            retryCount: retryCount - 1,
            file: file,
            line: line
        )
    }
}

func createRequest(
    genbaNeko: Data,
    denwaNeko: Data,
    pdf: Data,
    message: Data,
    file: StaticString = #filePath,
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
        pdf: pdf,
        message: message
    )
    return request
}

private func createBody(
    boundary: String,
    genbaNeko: Data,
    denwaNeko: Data,
    pdf: Data,
    message: Data
) -> Data {
    let genbaNekoBlock = [
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"genbaNeko\"; filename=\"genbaNeko\"\r\n".utf8),
        Data("Content-Type: image/jpeg\r\n".utf8),
        Data("\r\n".utf8),
        genbaNeko,
        Data("\r\n".utf8),
    ]
    let denwaNekoBlock = [
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"denwaNeko\"; filename=\"denwaNeko\"\r\n".utf8),
        Data("Content-Type: image/jpeg\r\n".utf8),
        Data("\r\n".utf8),
        denwaNeko,
        Data("\r\n".utf8),
    ]
    let pdfBlock = [
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"pdf\"; filename=\"example.pdf\"\r\n".utf8),
        Data("Content-Type: application/pdf\r\n".utf8),
        Data("\r\n".utf8),
        pdf,
        Data("\r\n".utf8),
    ]
    let messageBlock = [
        Data("--\(boundary)\r\n".utf8),
        Data("Content-Disposition: form-data; name=\"message\"\r\n".utf8),
        Data("\r\n".utf8),
        message,
        Data("\r\n".utf8),
    ]
    let footer = [
        Data("--\(boundary)--\r\n".utf8),
    ]
    return (genbaNekoBlock + denwaNekoBlock + pdfBlock + messageBlock + footer).reduce(Data(), +)
}
