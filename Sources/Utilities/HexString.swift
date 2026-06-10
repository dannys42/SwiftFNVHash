import Foundation

// MARK: - Test Utilities

package extension Sequence where Element == UInt8 {
    var asHexString: String {
        self.map { String($0, radix: 16) }
            .joined()
    }
}

package extension UInt32 {
    var asHexString: String {
        String(self, radix: 16)
    }
}

package extension UInt64 {
    var asHexString: String {
        String(self, radix: 16)
    }
}

package extension UInt128 {
    var asHexString: String {
        String(self, radix: 16)
    }
}
