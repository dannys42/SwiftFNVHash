import Foundation
import Testing
@testable import FNVHash

@Suite("FNV128Tests")
struct FNV128Tests {
    /// FNV-1 values from the canonical FNV reference implementation's test suite:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1Strings: [(String, UInt128)] = [
        ("", 0x6c62272e07bb0142_62b821756295c58d),
        ("hello", 0xf14b58486483d94f_708038798c29697f),
        ("foobar", 0x7896bfea9c3c64bf_6dc58353d2c293aa),
    ]

    /// FNV-1a values from the canonical FNV reference implementation's test suite:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1aStrings: [(String, UInt128)] = [
        ("", 0x6c62272e07bb0142_62b821756295c58d),
        ("a", 0xd228cb696f1a8caf_78912b704e4a8964),
        ("foobar", 0x343e1662793c64bf_6f0d3597ba446f18),
    ]

    /// Binary FNV-1a vector supplied by the project's 128-bit completeness plan.
    private static let binaryBytes: [UInt8] = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21, 0x01, 0xff, 0xed]
    private static let binaryFNV1a: UInt128 = 0x74202c600b051c16_5b1acafed10d1419

    @Test("Trusted FNV-1 vectors")
    func fnv1Vectors() {
        for (string, expected) in Self.fnv1Strings {
            #expect(FNV1.Hash128.hash(string: string) == expected)
        }
    }

    @Test("Trusted FNV-1a vectors")
    func fnv1aVectors() {
        for (string, expected) in Self.fnv1aStrings {
            #expect(FNV1a.Hash128.hash(string: string) == expected)
        }
        #expect(FNV1a.Hash128.hash(data: Self.binaryBytes) == Self.binaryFNV1a)
    }

    @Test("One-shot APIs accept Data, arrays, UTF-8 views, and single-pass sequences")
    func oneShotAPIs() {
        let bytes = Array("foobar".utf8)
        #expect(FNV1.Hash128.hash(data: Data(bytes)) == 0x7896bfea9c3c64bf_6dc58353d2c293aa)
        #expect(FNV1a.Hash128.hash(data: bytes) == 0x343e1662793c64bf_6f0d3597ba446f18)
        #expect(FNV1.Hash128.hash(data: "foobar".utf8) == 0x7896bfea9c3c64bf_6dc58353d2c293aa)
        #expect(FNV1a.Hash128.hash(data: SinglePassBytes128(bytes)) == 0x343e1662793c64bf_6f0d3597ba446f18)
    }

    @Test("Incremental APIs support individual bytes and split chunks")
    func incrementalAPIs() {
        var fnv1 = FNV1.Hash128()
        fnv1.update(byte: 0x66)
        fnv1.update(data: [0x6f, 0x6f])
        fnv1.update(data: Data([0x62, 0x61, 0x72]))
        #expect(fnv1.finalize() == 0x7896bfea9c3c64bf_6dc58353d2c293aa)

        var fnv1a = FNV1a.Hash128()
        fnv1a.update(data: "foo".utf8)
        fnv1a.update(byte: 0x62)
        fnv1a.update(data: SinglePassBytes128([0x61, 0x72]))
        #expect(fnv1a.finalize() == 0x343e1662793c64bf_6f0d3597ba446f18)
    }

    @Test("String hashing uses the complete Unicode UTF-8 representation")
    func unicodeUTF8() {
        let string = "FNV 🚀 café"
        #expect(FNV1.Hash128.hash(string: string) == FNV1.Hash128.hash(data: Array(string.utf8)))
        #expect(FNV1a.Hash128.hash(string: string) == FNV1a.Hash128.hash(data: Data(string.utf8)))
    }

    @Test("Long overflow-heavy input is equivalent across update paths")
    func overflowHeavyEquivalence() {
        let bytes = (0..<16_384).map { UInt8(truncatingIfNeeded: $0 &* 131 &+ 0xff) }

        var fnv1 = FNV1.Hash128()
        var fnv1a = FNV1a.Hash128()
        for chunkStart in stride(from: 0, to: bytes.count, by: 257) {
            let chunkEnd = min(chunkStart + 257, bytes.count)
            fnv1.update(data: bytes[chunkStart..<chunkEnd])
            fnv1a.update(data: bytes[chunkStart..<chunkEnd])
        }

        #expect(fnv1.finalize() == FNV1.Hash128.hash(data: bytes))
        #expect(fnv1a.finalize() == FNV1a.Hash128.hash(data: SinglePassBytes128(bytes)))
    }
}

private final class SinglePassBytes128: Sequence, IteratorProtocol {
    private let bytes: [UInt8]
    private var index = 0

    init(_ bytes: [UInt8]) { self.bytes = bytes }
    func makeIterator() -> SinglePassBytes128 { self }
    func next() -> UInt8? {
        guard index < bytes.count else { return nil }
        defer { index += 1 }
        return bytes[index]
    }
}
