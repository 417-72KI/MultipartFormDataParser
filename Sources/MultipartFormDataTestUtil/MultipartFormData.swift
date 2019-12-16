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
            if let contentDispositionMatches = try! NSRegularExpression(pattern: #"Content-Disposition: form-data; name="(?<name>.*?)"(; filename="(?<filename>.*?)")?"#, options: [])
                .firstMatch(in: string, options: [], range: .init(location: 0, length: string.count)) {
                element.name = (string as NSString).substring(with: contentDispositionMatches.range(withName: "name"))
                let filenameRange = contentDispositionMatches.range(withName: "filename")
                if filenameRange.length != 0 {
                    element.fileName = (string as NSString).substring(with: filenameRange)
                }
                continue
            }
            if let contentTypeMatches = try! NSRegularExpression(pattern: #"Content-Type: (?<mimetype>.*/.*)"#, options: []).firstMatch(in: string, options: [], range: .init(location: 0, length: string.count)) {
                element.mimeType = (string as NSString).substring(with: contentTypeMatches.range(withName: "mimetype"))
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
