import Foundation

public struct MultipartFormData {
    let elements: [Element]
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
        var element = Self.init(name: "", data: .init(), fileName: nil, mimeType: nil)
        for line in data {
            guard let string = String(data: line, encoding: .utf8) else {
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
            print(string)
            if element.data.isEmpty {
                element.data = line
            }
        }
        return element
    }
}
