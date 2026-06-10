import Foundation
import Testing
@testable import FNVHash

@Suite("FNV1-32 String Tests")
struct FNV1_32StringTests {

    // MARK: - Test Vectors

    /// Subset of FNV1-32 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let testVectors: [(input: String, expected: UInt32)] = [
        ("", 0x811c9dc5), // Index 0
        ("foo", 0x408f5e13), // Index 8
        ("chongo was here!\n", 0xdd002f35), // Index 39
        ("hello", 0xb6fa7167), // Index 86
    ]

    // MARK: - String Extension Tests

    @Test("String extension with test vectors")
    func stringExtensionTestVectors() async throws {
        for vector in Self.testVectors {
            let result = vector.input.fnv1_32()
            #expect(result == vector.expected, "FNV1-32 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Sequence Extension Tests

    @Test("Sequence extension with [UInt8] array")
    func sequenceExtensionWithArray() async throws {
        for vector in Self.testVectors {
            let input: [UInt8] = Array(vector.input.utf8)
            let result = input.fnv1_32()
            #expect(result == vector.expected, "FNV1-32 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    @Test("Sequence extension with empty sequence")
    func sequenceExtensionWithEmptySequence() async throws {
        let bytes: [UInt8] = []
        let result = bytes.fnv1_32()
        #expect(result == 0x811c9dc5, "Empty input should return offset basis")
    }

    @Test("Sequence extension with Data")
    func sequenceExtensionWithData() async throws {
        for vector in Self.testVectors {
            let input = Data(vector.input.utf8)
            let result = input.fnv1_32()
            #expect(result == vector.expected, "FNV1-32 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    @Test("Sequence extension with String.UTF8View")
    func sequenceExtensionWithUTF8View() async throws {
        for vector in Self.testVectors {
            let input = vector.input.utf8
            let result = input.fnv1_32()
            #expect(result == vector.expected, "FNV1-32 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Consistency Tests

    @Test("String extension matches sequence extension")
    func stringExtensionMatchesSequence() async throws {
        let input = "chongo was here!\n"
        let stringResult = input.fnv1_32()
        let sequenceResult = input.utf8.fnv1_32()
        #expect(stringResult == sequenceResult)
    }
}
