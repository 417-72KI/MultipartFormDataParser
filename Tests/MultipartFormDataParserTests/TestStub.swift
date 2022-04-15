import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa
typealias Image = NSImage
#endif

#if canImport(UIKit)
import UIKit
typealias Image = UIImage
#endif

#if canImport(OHHTTPStubs)
import OHHTTPStubs
import OHHTTPStubsSwift
#endif

import MultipartFormDataParser

func stubForUpload() {
    #if canImport(OHHTTPStubs)
    let condition = isHost("localhost")
        && isPath("/upload")
    stub(condition: condition, response: uploadTestStubResponse)
    #else
    StubURLProtocol.requestHandler = uploadTestStubResponse
    #endif
}

func clearStubs() {
    #if canImport(OHHTTPStubs)
    HTTPStubs.removeAllStubs()
    #endif
}

#if canImport(OHHTTPStubs)
private let uploadTestStubResponse: HTTPStubsResponseBlock = { request in
    let errorResponse = { (message: String) -> HTTPStubsResponse in
        .init(jsonObject: ["status": 403, "error": message], statusCode: 403, headers: ["Content-Type": "application/json"])
    }
    do {
        let data = try MultipartFormData.parse(from: request)
        guard let genbaNeko = data.element(forName: "genbaNeko") else { return errorResponse("genbaNeko") }
        guard let denwaNeko = data.element(forName: "denwaNeko") else { return errorResponse("denwaNeko") }
        guard let message = data.element(forName: "message") else { return errorResponse("message") }
        guard let _ = Image(data: genbaNeko.data) else { return errorResponse("Unexpected genbaNeko") }
        guard let _ = Image(data: denwaNeko.data) else { return errorResponse("Unexpected denwaNeko") }
        guard message.string == "Hello world!" else { return errorResponse("Unexpected message: \(message)") }
    } catch {
        return .init(error: error)
    }
    return .init(
        jsonObject: ["status": 200],
        statusCode: 200,
        headers: ["Content-Type": "application/json"]
    )
}
#else
private let uploadTestStubResponse: StubURLProtocol.RequestHandler = { request in
    let errorResponse = { (message: String) -> (Data?, HTTPURLResponse) in
        (
            #"{"status": 403, "error": "\#(message)"}"#.data(using: .utf8),
            HTTPURLResponse(url: request.url!,
                            statusCode: 403,
                            httpVersion: "HTTP/2",
                            headerFields: ["Content-Type": "application/json"])!
        )
    }
    do {
        let data = try MultipartFormData.parse(from: request)
        guard let genbaNeko = data.element(forName: "genbaNeko") else { return errorResponse("genbaNeko") }
        guard let denwaNeko = data.element(forName: "denwaNeko") else { return errorResponse("denwaNeko") }
        guard let message = data.element(forName: "message") else { return errorResponse("message") }
        guard let _ = Image(data: genbaNeko.data) else { return errorResponse("Unexpected genbaNeko") }
        guard let _ = Image(data: denwaNeko.data) else { return errorResponse("Unexpected denwaNeko") }
        guard message.string == "Hello world!" else { return errorResponse("Unexpected message: \(message)") }
        return (
            #"{"status": 200}"#.data(using: .utf8),
            HTTPURLResponse(url: request.url!,
                            statusCode: 200,
                            httpVersion: "HTTP/2",
                            headerFields: ["Content-Type": "application/json"])!
        )
    } catch {
        return errorResponse(error.localizedDescription)
    }
}
#endif
