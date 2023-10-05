import Foundation

extension MultipartFormData: Sequence {
    public typealias Iterator = [Element].Iterator

    public func makeIterator() -> Iterator {
        elements.makeIterator()
    }
}
