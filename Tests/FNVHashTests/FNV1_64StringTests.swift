import Foundation
import Testing
import Utilities
@testable import FNVHash

@Suite("FNV1-64 String Tests")
struct FNV1_64StringTests {

    // MARK: - Test Vectors

    /// Subset of FNV1-64 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let testVectors: [(input: String, expected: UInt64)] = [
        ("", 0xcbf29ce484222325), // Index 0
        ("foo", 0xd8cbc7186ba13533), // Index 8
        ("chongo was here!\n", 0xe0aca20b624e4235), // Index 39
        ("hello", 0x7b495389bdbdd4c7), // Index 86
    ]

    // MARK: - String Extension Tests

    @Test("String extension with test vectors")
    func stringExtensionTestVectors() async throws {
        for vector in Self.testVectors {
            let result = vector.input.fnv1_64()
            #expect(result == vector.expected, "FNV1-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Sequence Extension Tests

    @Test("Sequence extension with [UInt8] array")
    func sequenceExtensionWithArray() async throws {
        for vector in Self.testVectors {
            let input: [UInt8] = Array(vector.input.utf8)
            let result = input.fnv1_64()
            #expect(result == vector.expected, "FNV1-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    @Test("Sequence extension with empty sequence")
    func sequenceExtensionWithEmptySequence() async throws {
        let bytes: [UInt8] = []
        let result = bytes.fnv1_64()
        #expect(result == 0xcbf29ce484222325, "Empty input should return offset basis")
    }

    @Test("Sequence extension with Data")
    func sequenceExtensionWithData() async throws {
        for vector in Self.testVectors {
            let input = Data(vector.input.utf8)
            let result = input.fnv1_64()
            #expect(result == vector.expected, "FNV1-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    @Test("Sequence extension with String.UTF8View")
    func sequenceExtensionWithUTF8View() async throws {
        for vector in Self.testVectors {
            let input = vector.input.utf8
            let result = input.fnv1_64()
            #expect(result == vector.expected, "FNV1-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Consistency Tests

    @Test("String extension matches sequence extension")
    func stringExtensionMatchesSequence() async throws {
        let input = "chongo was here!\n"
        let stringResult = input.fnv1_64()
        let sequenceResult = input.utf8.fnv1_64()
        #expect(stringResult == sequenceResult)
    }
}
