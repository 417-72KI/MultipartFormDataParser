import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(UIKit)
import UIKit
typealias Image = UIImage
#elseif canImport(Cocoa)
import Cocoa
typealias Image = NSImage
#endif

import MultipartFormDataParser

func stubForUpload() {
    StubURLProtocol.requestHandler = uploadTestStubResponse
}

func clearStubs() {
    StubURLProtocol.requestHandler = nil
}

private let uploadTestStubResponse: StubURLProtocol.RequestHandler = { request in
    let errorResponse = { (message: String) -> (Data?, HTTPURLResponse) in
        (
            Data(#"{"status": 403, "error": "\#(message)"}"#.utf8),
            HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: "HTTP/2",
                headerFields: ["Content-Type": "application/json"]
            )!
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
            Data(#"{"status": 200}"#.utf8),
            HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/2",
                headerFields: ["Content-Type": "application/json"]
            )!
        )
    } catch {
        return errorResponse(error.localizedDescription)
    }
}
