import Foundation

public enum MultipartFormDataError: LocalizedError {
    case noContentType
    case invalidContentType(String)
    case httpBodyStreamEmpty
    case invalidHttpBodyStream

    // case testFailed(String)
    // case notImplemented
}

extension MultipartFormDataError {
    public var errorDescription: String? {
        switch self {
        case .noContentType: return "No Content-Type"
        case let .invalidContentType(contentType): return "Invalid Content-Type: \(contentType)"

        case .httpBodyStreamEmpty: return "HTTP body stream is empty."
        case .invalidHttpBodyStream: return "Invalid stream."

        // case let .testFailed(reason): return "Test failed: \(reason)"
        // case .notImplemented: return "Not implemented"
        }
    }
}
