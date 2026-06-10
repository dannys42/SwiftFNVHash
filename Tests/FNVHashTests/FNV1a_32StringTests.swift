import Foundation
import Testing
import Utilities
@testable import FNVHash

@Suite("FNV1a-32 String Tests")
struct FNV1a_32StringTests {

    // MARK: - Test Vectors

    /// Subset of FNV1a-32 test vectors from https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    static let testVectors: [(input: String, expected: UInt32)] = [
        ("", 0x811c9dc5), // Index 0
        ("foo", 0xa9f37ed7), // Index 8
        ("chongo was here!\n", 0xd49930d5), // Index 39
        ("hello", 0x4f9f2cab), // Index 86
    ]

    // MARK: - String Extension Tests

    @Test("String extension with test vectors")
    func stringExtensionTestVectors() async throws {
        for vector in Self.testVectors {
            let result = vector.input.fnv1a_32()
            #expect(result == vector.expected, "FNV1a-32 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Sequence Extension Tests

    @Test("Sequence extension with [UInt8] array")
    func sequenceExtensionWithArray() async throws {
        let bytes: [UInt8] = Array("foo".utf8)
        let result = bytes.fnv1a_32()
        #expect(result == 0xa9f37ed7)
    }

    @Test("Sequence extension with empty sequence")
    func sequenceExtensionWithEmptySequence() async throws {
        let bytes: [UInt8] = []
        let result = bytes.fnv1a_32()
        #expect(result == 0x811c9dc5, "Empty input should return offset basis")
    }

    @Test("Sequence extension with Data")
    func sequenceExtensionWithData() async throws {
        let data = Data("foo".utf8)
        let result = data.fnv1a_32()
        #expect(result == 0xa9f37ed7)
    }

    @Test("Sequence extension with String.UTF8View")
    func sequenceExtensionWithUTF8View() async throws {
        let result = "foo".utf8.fnv1a_32()
        #expect(result == 0xa9f37ed7)
    }

    // MARK: - Consistency Tests

    @Test("String extension matches sequence extension")
    func stringExtensionMatchesSequence() async throws {
        let input = "chongo was here!\n"
        let stringResult = input.fnv1a_32()
        let sequenceResult = input.utf8.fnv1a_32()
        #expect(stringResult == sequenceResult)
    }
}

