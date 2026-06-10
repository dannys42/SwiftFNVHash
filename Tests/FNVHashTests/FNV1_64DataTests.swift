import Foundation
import Testing
@testable import FNVHash

@Suite("FNV1-64 Data Tests")
struct FNV1_64DataTests {

    // MARK: - Test Vectors

    /// Subset of FNV1-64 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let dataTestVectors: [(bytes: [UInt8], expected: UInt64)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xd6b2b17bf4b71261),
        ([0x01, 0x00, 0x00, 0xff], 0x447bfb7f98e615b5),
        ([0xff, 0x00, 0x00, 0x02], 0xd6b2b17bf4b71262),
        ([0x02, 0x00, 0x00, 0xff], 0x3bd2807f93fe1660),
        ([0xff, 0x00, 0x00, 0x03], 0xd6b2b17bf4b71263),
        ([0x03, 0x00, 0x00, 0xff], 0x3329057f8f16170b),
        ([0xff, 0x00, 0x00, 0x04], 0xd6b2b17bf4b71264),
        ([0x04, 0x00, 0x00, 0xff], 0x2a7f8a7f8a2e19b6),
        ([0x40, 0x51, 0x4e, 0x44], 0x23d3767e64b2f98a),
        ([0x44, 0x4e, 0x51, 0x40], 0xff768d7e4f9d86a4),
        ([0x40, 0x51, 0x4e, 0x4a], 0x23d3767e64b2f984),
        ([0x4a, 0x4e, 0x51, 0x40], 0xccd1837e334e4aa6),
        ([0x40, 0x51, 0x4e, 0x54], 0x23d3767e64b2f99a),
    ]

    // MARK: - Data Tests

    @Test("Data with test vectors")
    func dataTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = Data(vector.bytes)
            let result = input.fnv1_64()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1-64 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    @Test("Byte array with test vectors")
    func byteArrayTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = vector.bytes
            let result = input.fnv1_64()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1-64 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    // MARK: - Consistency Tests

    @Test("Data matches byte array")
    func dataMatchesByteArray() async throws {
        for vector in Self.dataTestVectors {
            let data = Data(vector.bytes)
            let dataResult = data.fnv1_64()
            let arrayResult = vector.bytes.fnv1_64()
            #expect(dataResult == arrayResult, "Data and byte array results should match")
        }
    }
}
