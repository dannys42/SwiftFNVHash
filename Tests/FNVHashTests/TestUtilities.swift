import Foundation

// MARK: - Test Utilities

extension Sequence where Element == UInt8 {
    var asHexString: String {
        self.map { String($0, radix: 16) }
            .joined()
    }
}

extension UInt32 {
    var asHexString: String {
        String(self, radix: 16)
    }
}

extension UInt64 {
    var asHexString: String {
        String(self, radix: 16)
    }
}

extension UInt128 {
    var asHexString: String {
        String(self, radix: 16)
    }
}
