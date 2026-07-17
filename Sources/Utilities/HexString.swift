// MARK: - Hex String Utilities

public extension Sequence where Element == UInt8 {
    var asHexString: String {
        self.map {
            let hexadecimal = String($0, radix: 16)
            return hexadecimal.count == 1 ? "0" + hexadecimal : hexadecimal
        }
            .joined()
    }
}

public extension FixedWidthInteger where Self: UnsignedInteger {
    var asHexString: String {
        let hexadecimal = String(self, radix: 16)
        let paddingCount = Swift.max(0, Self.bitWidth / 4 - hexadecimal.count)
        return String(repeating: "0", count: paddingCount) + hexadecimal
    }
}
