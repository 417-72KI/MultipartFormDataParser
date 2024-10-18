import Foundation

extension Data {
    var bytes: [UInt8] { withUnsafeBytes([UInt8].init) }
}

extension Data {
    func split(separator: [UInt8]) -> [Data] {
        let bytes = self.bytes
        var result = [Data]()
        var position = 0
        for i in 0..<count - 1 {
            let current = Array(bytes[i..<(i + separator.count)])
            if current == separator {
                if i > 0 {
                    result.append(self[position..<i])
                }
                position = i + separator.count
            }
        }
        return result
    }

    func split(separator: Data) -> [Data] {
        split(separator: separator.bytes)
    }

    func split(separator: String) -> [Data] {
        split(separator: Data(separator.utf8))
    }
}
