#if os(Linux)
import Foundation

struct Image: Hashable {
    let data: Data

    init?(data: Data) {
        guard !data.isEmpty,
              data.prefix(2) == Data([0xFF, 0xD8]), // SOI marker
              data.suffix(2) == Data([0xFF, 0xD9])  // EOI marker
        else {
            print("Given data is not image.")
            return nil
        }
        if data.prefix(11).dropFirst(2) == Data([0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00]) {
            // JPEG
        } else {
            print("Given data is not an expected image format [jpg, png].")
            return nil
        }
        self.data = data
    }
}

#endif
