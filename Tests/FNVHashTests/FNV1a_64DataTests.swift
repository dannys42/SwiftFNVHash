import Foundation
import Testing
@testable import FNVHash

@Suite("FNV1a-64 Data Tests")
struct FNV1a64DataTests {

    // MARK: - Test Vectors

    /// Subset of FNV1-64 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let dataTestVectors: [(bytes: [UInt8], expected: UInt64)] = [
        ([0xff, 0x00, 0x00, 0x01], 0x6961196491cc682d), // Index 88
        ([0x01, 0x00, 0x00, 0xff], 0xad2bb1774799dfe9),
        ([0xff, 0x00, 0x00, 0x02], 0x6961166491cc6314),
        ([0x02, 0x00, 0x00, 0xff], 0x8d1bb3904a3b1236),
        ([0xff, 0x00, 0x00, 0x03], 0x6961176491cc64c7),
        ([0x03, 0x00, 0x00, 0xff], 0xed205d87f40434c7),
        ([0xff, 0x00, 0x00, 0x04], 0x6961146491cc5fae),
        ([0x04, 0x00, 0x00, 0xff], 0xcd3baf5e44f8ad9c),
        ([0x40, 0x51, 0x4e, 0x44], 0xe3b36596127cd6d8),
        ([0x44, 0x4e, 0x51, 0x40], 0xf77f1072c8e8a646),
        ([0x40, 0x51, 0x4e, 0x4a], 0xe3b36396127cd372),
        ([0x4a, 0x4e, 0x51, 0x40], 0x6067dce9932ad458),
        ([0x40, 0x51, 0x4e, 0x54], 0xe3b37596127cf208), // Index 100
    ]

    // MARK: - Data Tests

    @Test("Data with test vectors")
    func dataTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = Data(vector.bytes)
            let result = input.fnv1a_64()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1a-64 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    @Test("Byte array with test vectors")
    func byteArrayTestVectors() async throws {
        for vector in Self.dataTestVectors {
            let input = vector.bytes
            let result = input.fnv1a_64()

            let inputString = input.asHexString
            let resultString = result.asHexString
            let expectString = vector.expected.asHexString
            #expect(result == vector.expected, "FNV1a-64 of \(inputString)  returned \(resultString), expected \(expectString),")
        }
    }

    // MARK: - Consistency Tests

    @Test("Data matches byte array")
    func dataMatchesByteArray() async throws {
        for vector in Self.dataTestVectors {
            let data = Data(vector.bytes)
            let dataResult = data.fnv1a_64()
            let arrayResult = vector.bytes.fnv1a_64()
            #expect(dataResult == arrayResult, "Data and byte array results should match")
        }
    }
}
