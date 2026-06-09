import Foundation
import Testing
@testable import FNVHash

@Suite("FNV1a-64 Tests")
struct FNV1a64Tests {

    // MARK: - Test Vectors

    /// Standard FNV1a-64 test vectors from http://www.isthe.com/chongo/tech/comp/fnv/
    static let testVectors: [(input: String, expected: UInt64)] = [
        ("", 0xcbf29ce484222325),
        ("foo", 0xdcb27518fed9d577),
        ("chongo was here!\n", 0x46810940eff5f915),
    ]

    // MARK: - String Extension Tests

    @Test("String extension with test vectors")
    func stringExtensionTestVectors() async throws {
        for vector in Self.testVectors {
            let result = vector.input.fnv1a_64()
            #expect(result == vector.expected, "FNV1a-64 of \"\(vector.input)\" should be \(String(vector.expected, radix: 16))")
        }
    }

    // MARK: - Generic Function Tests

    @Test("Generic function with [UInt8] array")
    func genericFunctionWithArray() async throws {
        let bytes: [UInt8] = Array("foo".utf8)
        let result = fnv1a_64(bytes)
        #expect(result == 0xdcb27518fed9d577)
    }

    @Test("Generic function with empty sequence")
    func genericFunctionWithEmptySequence() async throws {
        let bytes: [UInt8] = []
        let result = fnv1a_64(bytes)
        #expect(result == 0xcbf29ce484222325, "Empty input should return offset basis")
    }

    @Test("Generic function with Data")
    func genericFunctionWithData() async throws {
        let data = Data("foo".utf8)
        let result = fnv1a_64(data)
        #expect(result == 0xdcb27518fed9d577)
    }

    @Test("Generic function with String.UTF8View")
    func genericFunctionWithUTF8View() async throws {
        let result = fnv1a_64("foo".utf8)
        #expect(result == 0xdcb27518fed9d577)
    }

    // MARK: - Consistency Tests

    @Test("String extension matches generic function")
    func stringExtensionMatchesGeneric() async throws {
        let input = "chongo was here!\n"
        let stringResult = input.fnv1a_64()
        let genericResult = fnv1a_64(input.utf8)
        #expect(stringResult == genericResult)
    }
}
