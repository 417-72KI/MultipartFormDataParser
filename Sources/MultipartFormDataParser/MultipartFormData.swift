import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct MultipartFormData {
    public let elements: [Element]
}

public extension MultipartFormData {
    func element(forName name: String) -> Element? {
        elements.first(where: { $0.name == name })
    }
}

// MARK: - Static functions
public extension MultipartFormData {
    static func parse(from request: URLRequest) throws -> Self {
        try MultipartFormDataParser.parse(request)
    }
}

// MARK: -
public extension MultipartFormData {
    struct Element {
        public private(set) var name: String
        public private(set) var data: Data
        public private(set) var fileName: String?
        public private(set) var mimeType: String?
    }
}

public extension MultipartFormData.Element {
    var string: String? { String(data: data, encoding: .utf8) }
}

extension MultipartFormData.Element {
    static func from(_ data: [Data]) -> Self {
        var element = Self(name: "", data: .init(), fileName: nil, mimeType: nil)
        for line in data {
            guard let string = String(data: line, encoding: .utf8) else {
                element.data = line
                continue
            }

            if let contentDispositionMatches = try! #/Content-Disposition: form-data; name="(?<name>.*?)"(; filename="(?<filename>.*?)")?/#.firstMatch(in: string) {
                element.name = String(contentDispositionMatches.output.name)
                if let filename = contentDispositionMatches.output.filename {
                    element.fileName = String(filename)
                }
                continue
            }
            if let mimeTypeMatches = try! #/Content-Type: (?<mimetype>.*/.*)/#.firstMatch(in: string) {
                element.mimeType = String(mimeTypeMatches.output.mimetype)
                continue
            }
            if element.data.isEmpty {
                element.data = line
            }
        }
        return element
    }
}
