import Foundation

extension MultipartFormData: Sequence {
    public typealias Iterator = Array<Element>.Iterator

    public func makeIterator() -> Iterator {
        elements.makeIterator()
    }
}
