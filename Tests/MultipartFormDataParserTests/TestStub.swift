#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa
typealias Image = NSImage
#endif

#if canImport(UIKit)
import UIKit
typealias Image = UIImage
#endif

import OHHTTPStubs
import OHHTTPStubsSwift

import MultipartFormDataParser

func stubForUpload() {
    let condition = isHost("localhost")
        && isPath("/upload")
    stub(condition: condition, response: uploadTestStubResponse)
}

func clearStubs() {
    HTTPStubs.removeAllStubs()
}

private var uploadTestStubResponse: HTTPStubsResponseBlock = { request in
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
