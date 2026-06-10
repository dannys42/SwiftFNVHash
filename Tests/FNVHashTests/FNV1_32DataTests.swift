import Foundation
import Testing
import Utilities
@testable import FNVHash

@Suite("FNV1-32 Data Tests")
struct FNV1_32DataTests {

    // MARK: - Test Vectors

    /// Subset of FNV1-32 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let dataTestVectors: [(bytes: [UInt8], expected: UInt32)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xb78320a1), // Index 88
        ([0x01, 0x00, 0x00, 0xff], 0x0caf4135),
        ([0xff, 0x00, 0x00, 0x02], 0xb78320a2),
        ([0x02, 0x00, 0x00, 0xff], 0xcdc88e80),
        ([0xff, 0x00, 0x00, 0x03], 0xb78320a3),
        ([0x03, 0x00, 0x00, 0xff], 0x8ee1dbcb),
        ([0xff, 0x00, 0x00, 0x04], 0xb78320a4),
        ([0x04, 0x00, 0x00, 0xff], 0x4ffb2716),
        ([0x40, 0x51, 0x4e, 0x44], 0x860632aa),
        ([0x44, 0x4e, 0x51, 0x40], 0xcc2c5c64),
        ([0x40, 0x51, 0x4e, 0x4a], 0x860632a4),
        ([0x4a, 0x4e, 0x51, 0x40], 0x2a7ec4a6),
        ([0x40, 0x51, 0x4e, 0x54], 0x860632ba), // Index 100
    ]

    // MARK: - Data Tests

    @Test("Data with test vectors")
    func dataTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = Data(vector.bytes)
            let result = input.fnv1_32()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1-32 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    @Test("Byte array with test vectors")
    func byteArrayTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = vector.bytes
            let result = input.fnv1_32()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1-32 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    // MARK: - Consistency Tests

    @Test("Data matches byte array")
    func dataMatchesByteArray() async throws {
        for vector in Self.dataTestVectors {
            let data = Data(vector.bytes)
            let dataResult = data.fnv1_32()
            let arrayResult = vector.bytes.fnv1_32()
            #expect(dataResult == arrayResult, "Data and byte array results should match")
        }
    }
}
