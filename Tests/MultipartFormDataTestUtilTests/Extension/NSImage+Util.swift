#if canImport(Cocoa)
import Cocoa

extension NSImage {
    var jpegRepresentation: Data? {
        guard let bitmap = representations.first as? NSBitmapImageRep else { return nil }
        return bitmap.representation(using: .jpeg, properties: [:])
    }
}
#endif
