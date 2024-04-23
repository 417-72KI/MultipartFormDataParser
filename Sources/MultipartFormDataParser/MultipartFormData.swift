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
    // swiftlint:disable:next non_optional_string_data_conversion
    var string: String? { String(data: data, encoding: .utf8) } // binaries should be nil
}

extension MultipartFormData.Element {
    static func from(_ data: [Data]) -> Self {
        var element = Self(name: "", data: .init(), fileName: nil, mimeType: nil)
        for line in data {
            // swiftlint:disable:next non_optional_string_data_conversion
            guard let string = String(data: line, encoding: .utf8) else { // binaries should be nil
                element.data = line
                continue
            }
            if let contentDispositionMatches = RegularExpression(pattern: #"Content-Disposition: form-data; name="(?<name>.*?)"(; filename="(?<filename>.*?)")?"#)
                .firstMatch(in: string) {
                if let name = contentDispositionMatches.grouped(withName: "name") {
                    element.name = name
                }
                if let filename = contentDispositionMatches.grouped(withName: "filename") {
                    element.fileName = filename
                }
                continue
            }
            if let mimeType = RegularExpression(pattern: #"Content-Type: (?<mimetype>.*/.*)"#)
                .firstMatch(in: string)
                .flatMap({ $0.grouped(withName: "mimetype") }) {
                element.mimeType = mimeType
                continue
            }
            if element.data.isEmpty {
                element.data = line
            }
        }
        return element
    }
}
