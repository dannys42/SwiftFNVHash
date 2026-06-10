import Foundation
import Testing
@testable import FNVHash

@Suite("FNV1a-64 String Tests")
struct FNV1a64Tests {

    // MARK: - Test Vectors

    /// Subset of FNV1a-64 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let testVectors: [(input: String, expected: UInt64)] = [
        ("", 0xcbf29ce484222325), // Index 0
        ("foo", 0xdcb27518fed9d577), // Index 8
        ("chongo was here!\n", 0x46810940eff5f915), // Index 39
        ("hello", 0xa430d84680aabd0b), // Index 86
    ]

    // MARK: - String Extension Tests

    @Test("String extension with test vectors")
    func stringExtensionTestVectors() async throws {
        for vector in Self.testVectors {
            let result = vector.input.fnv1a_64()
            #expect(result == vector.expected, "FNV1a-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Sequence Extension Tests

    @Test("Sequence extension with [UInt8] array")
    func sequenceExtensionWithArray() async throws {
        let bytes: [UInt8] = Array("foo".utf8)
        let result = bytes.fnv1a_64()
        #expect(result == 0xdcb27518fed9d577)
    }

    @Test("Sequence extension with empty sequence")
    func sequenceExtensionWithEmptySequence() async throws {
        let bytes: [UInt8] = []
        let result = bytes.fnv1a_64()
        #expect(result == 0xcbf29ce484222325, "Empty input should return offset basis")
    }

    @Test("Sequence extension with Data")
    func sequenceExtensionWithData() async throws {
        let data = Data("foo".utf8)
        let result = data.fnv1a_64()
        #expect(result == 0xdcb27518fed9d577)
    }

    @Test("Sequence extension with String.UTF8View")
    func sequenceExtensionWithUTF8View() async throws {
        let result = "foo".utf8.fnv1a_64()
        #expect(result == 0xdcb27518fed9d577)
    }

    // MARK: - Consistency Tests

    @Test("String extension matches sequence extension")
    func stringExtensionMatchesSequence() async throws {
        let input = "chongo was here!\n"
        let stringResult = input.fnv1a_64()
        let sequenceResult = input.utf8.fnv1a_64()
        #expect(stringResult == sequenceResult)
    }
}
