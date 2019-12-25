import Foundation

struct RegularExpression {
    private let regex: NSRegularExpression

    init(pattern: String) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            fatalError("\(error)")
        }
    }
}

extension RegularExpression {
    func firstMatch(in string: String) -> MatchingResult? {
        guard let result = regex.firstMatch(in: string, options: [], range: .init(location: 0, length: string.count)) else { return nil }
        return .init(string: string, result: result)
    }
}

extension RegularExpression {
    struct MatchingResult {
        private let string: NSString
        private let result: NSTextCheckingResult

        init(string: String, result: NSTextCheckingResult) {
            self.string = string as NSString
            self.result = result
        }
    }
}

extension RegularExpression.MatchingResult {
    func grouped(withName name: String) -> String? {
        let range = result.range(withName: name)
        guard range.length > 0 else { return nil }
        return string.substring(with: range)
    }
}
