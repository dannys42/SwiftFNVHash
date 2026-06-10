import Foundation

// MARK: - Hex String Utilities

public extension Sequence where Element == UInt8 {
    var asHexString: String {
        self.map { String($0, radix: 16) }
            .joined()
    }
}

public extension FixedWidthInteger {
    var asHexString: String {
        String(self, radix: 16)
    }
}
