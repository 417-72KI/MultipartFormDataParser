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
    static func from(_ data: [Data]) -> Self? {
        var element = Self(name: "", data: .init(), fileName: nil, mimeType: nil)
        guard let firstLine = data.first
            .flatMap({ String(data: $0, encoding: .utf8) }),
              let contentDispositionMatches = matchContentDisposition(in: firstLine) else {
            return nil
        }
        element.name = String(contentDispositionMatches.output.name)
        if let filename = contentDispositionMatches.output.filename {
            element.fileName = String(filename)
        }
        for line in data.dropFirst() {
            guard let string = String(data: line, encoding: .utf8) else {
                element.data.append(line)
                element.data.append(Data("\r\n".utf8))
                continue
            }
            if let mimeTypeMatches = matchMimeType(in: string) {
                element.mimeType = String(mimeTypeMatches.output.mimetype)
                continue
            }
            if element.data.isEmpty {
                element.data = line
            } else {
                element.data.append(line)
                element.data.append(Data("\r\n".utf8))
            }
        }
        if element.data.suffix(2) == Data("\r\n".utf8) {
            element.data.removeLast(2)
        }
        return element
    }
}

private extension MultipartFormData.Element {
    // swiftlint:disable:next large_tuple
    static func matchContentDisposition(in string: String) -> Regex<(Substring, name: Substring, Substring?, filename: Substring?)>.Match? {
        try! #/Content-Disposition: form-data; name="(?<name>.*?)"(; filename="(?<filename>.*?)")?/#
            .firstMatch(in: string)
    }

    static func matchMimeType(in string: String) -> Regex<(Substring, mimetype: Substring)>.Match? {
        try! #/Content-Type: (?<mimetype>.*/.*)/#
            .firstMatch(in: string)
    }
}
