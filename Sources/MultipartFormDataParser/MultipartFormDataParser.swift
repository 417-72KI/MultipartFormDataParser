import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let crlf = "\r\n"

struct MultipartFormDataParser: Sendable {
    private let boundary: String
}

// MARK: - Functions
private extension MultipartFormDataParser {
    func parse(_ stream: InputStream) throws -> MultipartFormData {
        try parse(extractData(from: stream))
    }

    func parse(_ data: Data) throws -> MultipartFormData {
        let data = data.split(separator: crlf)
        let elements = try split(data, withBoundary: boundary)
            .compactMap(MultipartFormData.Element.from)
        return MultipartFormData(elements: elements)
    }

    func extractData(from stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        while stream.hasBytesAvailable {
            // swiftlint:disable:next no_magic_numbers
            var buffer = [UInt8](repeating: 0, count: 512)
            let readCount = stream.read(&buffer, maxLength: buffer.count)
            guard readCount > 0 else { break }
            data.append(buffer, count: readCount)
        }
        return data
    }

    func split(_ data: [Data], withBoundary boundary: String) throws -> [[Data]] {
        var result = [[Data]]()
        for line in data {
            // swiftlint:disable:next non_optional_string_data_conversion
            switch String(data: line, encoding: .utf8) { // binaries should be nil
            case "--\(boundary)--": // end of body
                return result
            case "--\(boundary)":
                result.append([])
            default:
                if let last = result.indices.last {
                    result[last].append(line)
                }
            }
        }
        throw MultipartFormDataError.invalidHttpBodyStream
    }
}

// MARK: - Static functions
extension MultipartFormDataParser {
    static func parse(_ request: URLRequest) throws -> MultipartFormData {
        guard let contentType = request.value(forHTTPHeaderField: "Content-Type") else {
            throw MultipartFormDataError.noContentType
        }
        let regex = #/multipart/form-data; boundary=(.*)/#
        guard let boundaryMatches = try! regex.firstMatch(in: contentType) else {
            throw MultipartFormDataError.invalidContentType(contentType)
        }
        let boundary = String(boundaryMatches.output.1)
        if let body = request.httpBody, !body.isEmpty {
            return try Self(boundary: boundary).parse(body)
        }
        guard let stream = request.httpBodyStream else {
            throw MultipartFormDataError.httpBodyStreamEmpty
        }
        return try Self(boundary: boundary).parse(stream)
    }
}
