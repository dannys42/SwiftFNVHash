import Foundation
import Testing
@testable import FNVCLI

@Suite("FNV CLI")
struct FNVCLITests {
    @Test("all width and algorithm pairs dispatch")
    func allDispatchPairs() throws {
        let bytes = Data("hello".utf8)

        #expect(try FNVCLI.hash(data: bytes, bits: .bits32, algorithm: .fnv1) == "b6fa7167")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits32, algorithm: .fnv1a) == "4f9f2cab")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits64, algorithm: .fnv1) == "7b495389bdbdd4c7")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits64, algorithm: .fnv1a) == "a430d84680aabd0b")

        if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *) {
            #expect(try FNVCLI.hash(data: bytes, bits: .bits128, algorithm: .fnv1) == "f14b58486483d94f708038798c29697f")
            #expect(try FNVCLI.hash(data: bytes, bits: .bits128, algorithm: .fnv1a) == "e3e1efd54283d94f7081314b599d31b3")
        }
    }

    @Test("hash result uses checksum-compatible display")
    func hashResultDescription() {
        let result = HashResult(index: 4, hashString: "00000001", filename: "input.bin")
        #expect(result.description == "00000001  input.bin")
    }
}
