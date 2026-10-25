import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Testing
import MultipartFormDataParser

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

#if canImport(APIKit)
import APIKit
#endif

private var isLinux: Bool {
    #if os(Linux)
    true
    #else
    false
    #endif
}

struct MultipartFormDataParserTests {
    @Test
    func request() throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)
        let request = createRequest(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message
        )
        let data = try MultipartFormData.parse(from: request)
        #expect(data.element(forName: "genbaNeko")?.data == genbaNeko)
        #expect(data.element(forName: "denwaNeko")?.data == denwaNeko)
        #expect(data.element(forName: "message")?.string == "Hello world!")
    }

    @Test
    func sequence() throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)
        let request = createRequest(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message
        )
        let data = try MultipartFormData.parse(from: request)
        #expect(["genbaNeko", "denwaNeko", "pdf", "message"] == data.map(\.name))
        #expect([genbaNeko, denwaNeko, pdf, Data("Hello world!".utf8)] == data.map(\.data))
    }

    // MARK: Failure
    @Test
    func emptyBody() throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=foobar", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("".utf8)
        let error = try #require(throws: (any Error).self) {
            try MultipartFormData.parse(from: request)
        }
        #expect(error.localizedDescription == "HTTP body stream is empty.")
    }

    @Test
    func noContentType() throws {
        let request = URLRequest(url: URL(string: "https://localhost/empty")!)
        let error = try #require(throws: (any Error).self) {
            try MultipartFormData.parse(from: request)
        }
        #expect(error.localizedDescription == "No Content-Type")
    }

    @Test
    func invalidContentType() throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("".utf8)
        let error = try #require(throws: (any Error).self) {
            try MultipartFormData.parse(from: request)
        }
        #expect(error.localizedDescription == "Invalid Content-Type: application/json")
    }

    @Test(arguments: [
        Data("--foobar".utf8),     // body not contains `CRLF`
        Data("foobar\r\n".utf8),   // body not started with boundary
        Data("--foobar\r\n".utf8), // body not end with `--{boundary}--`
    ])
    func invalidBody(_ body: Data) throws {
        var request = URLRequest(url: URL(string: "https://localhost/empty")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=foobar", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let error = try #require(throws: (any Error).self) {
            try MultipartFormData.parse(from: request)
        }
        #expect(error.localizedDescription == "Invalid stream.")
    }
}

// MARK: using 3rd-party libraries
#if canImport(Alamofire)
extension MultipartFormDataParserTests {
    @Test
    func alamofire() async throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadWithAlamoFire(
            session(configuration: .stubbed(for: UploadTestStubResponse.self)),
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            message: message
        )
        #expect(result.status == 200)
        #expect(result.error == nil)
    }
}
#endif

#if canImport(APIKit)
extension MultipartFormDataParserTests {
    @Test
    func apiKit() async throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)

        let request = requestWithAPIKit(
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message
        )
        let data = try MultipartFormData.parse(from: request.buildURLRequest())
        #expect(data.element(forName: "genbaNeko")?.data == genbaNeko)
        #expect(data.element(forName: "denwaNeko")?.data == denwaNeko)
        #expect(data.element(forName: "message")?.string == "Hello world!")

        let result = try await uploadWithAPIKit(
            session(configuration: .stubbed(for: UploadTestStubResponse.self)),
            request: request,
        )
        #expect(result.status == 200)
        #expect(result.error == nil)
    }
}
#endif

// MARK: URLSession
extension MultipartFormDataParserTests {
    // FIXME: There is no way to get body stream with `URLSessionUploadTask`.
    @Test(.disabled(if: isLinux, "Stubbing `URLSessionUploadTask` in Linux is not supported."))
    func urlSessionUploadTask() async throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadURLSessionUpload(
            URLSession(configuration: .stubbed(for: UploadTestStubResponse.self)),
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message
        )
        #expect(result.status == 200)
        #expect(result.error == nil)
    }

    @Test
    func urlSessionDataTask() async throws {
        let genbaNeko = try #require(genbaNeko)
        let denwaNeko = try #require(denwaNeko)
        let message = Data("Hello world!".utf8)
        let result = try await uploadURLSessionData(
            URLSession(configuration: .stubbed(for: UploadTestStubResponse.self)),
            genbaNeko: genbaNeko,
            denwaNeko: denwaNeko,
            pdf: pdf,
            message: message
        )
        #expect(result.status == 200)
        #expect(result.error == nil)
    }
}

private extension MultipartFormDataParserTests {
    var genbaNeko: Data? {
        #if canImport(UIKit)
        return UIImage(data: TestResource.genbaNeko)?
            .jpegData(compressionQuality: 1)
        #elseif canImport(Cocoa)
        return NSImage(data: TestResource.genbaNeko)?
            .jpegRepresentation
        #elseif os(Linux)
        return Image(data: TestResource.genbaNeko)?.data
        #else
        return TestResource.genbaNeko
        #endif
    }

    var denwaNeko: Data? {
        #if canImport(UIKit)
        return UIImage(data: TestResource.denwaNeko)?
            .jpegData(compressionQuality: 1)
        #elseif canImport(Cocoa)
        return NSImage(data: TestResource.denwaNeko)?
            .jpegRepresentation
        #elseif os(Linux)
        return Image(data: TestResource.denwaNeko)?.data
        #else
        return TestResource.denwaNeko
        #endif
    }

    var pdf: Data { TestResource.pdf }
}
