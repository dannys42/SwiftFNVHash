import Foundation
import Testing
import Utilities
@testable import FNVHash

@Suite("FNV1a-32 Data Tests")
struct FNV1a_32DataTests {

    // MARK: - Test Vectors

    /// Subset of FNV1a-32 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let dataTestVectors: [(bytes: [UInt8], expected: UInt32)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xc48fb86d), // Index 88
        ([0x01, 0x00, 0x00, 0xff], 0x2269f369),
        ([0xff, 0x00, 0x00, 0x02], 0xc18fb3b4),
        ([0x02, 0x00, 0x00, 0xff], 0x50ef1236),
        ([0xff, 0x00, 0x00, 0x03], 0xc28fb547),
        ([0x03, 0x00, 0x00, 0xff], 0x96c3bf47),
        ([0xff, 0x00, 0x00, 0x04], 0xbf8fb08e),
        ([0x04, 0x00, 0x00, 0xff], 0xf3e4d49c),
        ([0x40, 0x51, 0x4e, 0x44], 0x32179058),
        ([0x44, 0x4e, 0x51, 0x40], 0x280bfee6),
        ([0x40, 0x51, 0x4e, 0x4a], 0x30178d32),
        ([0x4a, 0x4e, 0x51, 0x40], 0x21addaf8),
        ([0x40, 0x51, 0x4e, 0x54], 0x4217a988), // Index 100
    ]

    // MARK: - Data Tests

    @Test("Data with test vectors")
    func dataTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = Data(vector.bytes)
            let result = input.fnv1a_32()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1a-32 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    @Test("Byte array with test vectors")
    func byteArrayTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = vector.bytes
            let result = input.fnv1a_32()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1a-32 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    // MARK: - Consistency Tests

    @Test("Data matches byte array")
    func dataMatchesByteArray() async throws {
        for vector in Self.dataTestVectors {
            let data = Data(vector.bytes)
            let dataResult = data.fnv1a_32()
            let arrayResult = vector.bytes.fnv1a_32()
            #expect(dataResult == arrayResult, "Data and byte array results should match")
        }
    }
}

