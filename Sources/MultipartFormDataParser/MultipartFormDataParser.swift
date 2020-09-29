import Foundation

private let crlf = "\r\n"

struct MultipartFormDataParser {
    private let boundary: String
}

// MARK: - Functions
private extension MultipartFormDataParser {
    func parse(_ stream: InputStream) throws -> MultipartFormData {
        let data = extractData(from: stream)
            .split(separator: crlf)
        let elements = try split(data, withBoundary: boundary)
            .compactMap(MultipartFormData.Element.from)
        return MultipartFormData(elements: elements)
    }

    func extractData(from stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        while stream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: 512)
            let readCount = stream.read(&buffer, maxLength: buffer.count)
            guard readCount > 0 else { break }
            data.append(buffer, count: readCount)
        }
        return data
    }

    func split(_ data: [Data], withBoundary boundary: String) throws -> [[Data]] {
        var result = [[Data]]()
        for d in data { // swiftlint:disable:this identifier_name
            switch String(data: d, encoding: .utf8) {
            case "--\(boundary)--"?:
                return result
            case "--\(boundary)"?:
                result.append([])
            default:
                if let last = result.indices.last {
                    result[last].append(d)
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
        let regex = RegularExpression(pattern: #"multipart/form-data; boundary=(.*)"#)
        guard let boundary = regex.firstMatch(in: contentType)?.range(at: 1) else {
            throw MultipartFormDataError.invalidContentType(contentType)
        }
        guard let stream = request.httpBodyStream else {
            throw MultipartFormDataError.httpBodyStreamEmpty
        }
        return try Self(boundary: boundary).parse(stream)
    }
}
