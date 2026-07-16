import Foundation
import Testing
@testable import FNVHash

@Suite("FNV64Tests")
struct FNV64Tests {
    /// FNV-1 values from the pinned upstream test vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1Strings: [(String, UInt64)] = [
        ("", 0xcbf29ce484222325),
        ("foo", 0xd8cbc7186ba13533),
        ("chongo was here!\n", 0xe0aca20b624e4235),
        ("hello", 0x7b495389bdbdd4c7),
    ]

    /// FNV-1a values standardized by RFC 9923 and present in the pinned upstream vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1aStrings: [(String, UInt64)] = [
        ("", 0xcbf29ce484222325),
        ("foo", 0xdcb27518fed9d577),
        ("chongo was here!\n", 0x46810940eff5f915),
        ("hello", 0xa430d84680aabd0b),
    ]

    /// FNV-1 values from the pinned upstream test vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1Bytes: [([UInt8], UInt64)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xd6b2b17bf4b71261), ([0x01, 0x00, 0x00, 0xff], 0x447bfb7f98e615b5),
        ([0xff, 0x00, 0x00, 0x02], 0xd6b2b17bf4b71262), ([0x02, 0x00, 0x00, 0xff], 0x3bd2807f93fe1660),
        ([0xff, 0x00, 0x00, 0x03], 0xd6b2b17bf4b71263), ([0x03, 0x00, 0x00, 0xff], 0x3329057f8f16170b),
        ([0xff, 0x00, 0x00, 0x04], 0xd6b2b17bf4b71264), ([0x04, 0x00, 0x00, 0xff], 0x2a7f8a7f8a2e19b6),
        ([0x40, 0x51, 0x4e, 0x44], 0x23d3767e64b2f98a), ([0x44, 0x4e, 0x51, 0x40], 0xff768d7e4f9d86a4),
        ([0x40, 0x51, 0x4e, 0x4a], 0x23d3767e64b2f984), ([0x4a, 0x4e, 0x51, 0x40], 0xccd1837e334e4aa6),
        ([0x40, 0x51, 0x4e, 0x54], 0x23d3767e64b2f99a),
    ]

    /// FNV-1a values standardized by RFC 9923 and present in the pinned upstream vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1aBytes: [([UInt8], UInt64)] = [
        ([0xff, 0x00, 0x00, 0x01], 0x6961196491cc682d), ([0x01, 0x00, 0x00, 0xff], 0xad2bb1774799dfe9),
        ([0xff, 0x00, 0x00, 0x02], 0x6961166491cc6314), ([0x02, 0x00, 0x00, 0xff], 0x8d1bb3904a3b1236),
        ([0xff, 0x00, 0x00, 0x03], 0x6961176491cc64c7), ([0x03, 0x00, 0x00, 0xff], 0xed205d87f40434c7),
        ([0xff, 0x00, 0x00, 0x04], 0x6961146491cc5fae), ([0x04, 0x00, 0x00, 0xff], 0xcd3baf5e44f8ad9c),
        ([0x40, 0x51, 0x4e, 0x44], 0xe3b36596127cd6d8), ([0x44, 0x4e, 0x51, 0x40], 0xf77f1072c8e8a646),
        ([0x40, 0x51, 0x4e, 0x4a], 0xe3b36396127cd372), ([0x4a, 0x4e, 0x51, 0x40], 0x6067dce9932ad458),
        ([0x40, 0x51, 0x4e, 0x54], 0xe3b37596127cf208),
    ]

    @Test("Trusted FNV-1 vectors")
    func fnv1Vectors() {
        for (string, expected) in Self.fnv1Strings {
            #expect(FNV1.Hash64.hash(string: string) == expected)
        }
        for (bytes, expected) in Self.fnv1Bytes {
            #expect(FNV1.Hash64.hash(data: bytes) == expected)
            #expect(FNV1.Hash64.hash(data: Data(bytes)) == expected)
        }
    }

    @Test("Trusted FNV-1a vectors")
    func fnv1aVectors() {
        for (string, expected) in Self.fnv1aStrings {
            #expect(FNV1a.Hash64.hash(string: string) == expected)
        }
        for (bytes, expected) in Self.fnv1aBytes {
            #expect(FNV1a.Hash64.hash(data: bytes) == expected)
            #expect(FNV1a.Hash64.hash(data: Data(bytes)) == expected)
        }
    }

    @Test("One-shot APIs accept Data, arrays, UTF-8 views, and single-pass sequences")
    func oneShotAPIs() {
        let bytes = Array("foo".utf8)
        #expect(FNV1.Hash64.hash(data: Data(bytes)) == 0xd8cbc7186ba13533)
        #expect(FNV1a.Hash64.hash(data: bytes) == 0xdcb27518fed9d577)
        #expect(FNV1.Hash64.hash(data: "foo".utf8) == 0xd8cbc7186ba13533)
        #expect(FNV1a.Hash64.hash(data: SinglePassBytes64(bytes)) == 0xdcb27518fed9d577)
    }

    @Test("Incremental APIs support bytes and split chunks")
    func incrementalAPIs() {
        var fnv1 = FNV1.Hash64()
        fnv1.update(byte: 0x66)
        fnv1.update(data: [0x6f])
        fnv1.update(data: Data([0x6f]))
        #expect(fnv1.finalize() == 0xd8cbc7186ba13533)

        var fnv1a = FNV1a.Hash64()
        fnv1a.update(data: "f".utf8)
        fnv1a.update(byte: 0x6f)
        fnv1a.update(data: SinglePassBytes64([0x6f]))
        #expect(fnv1a.finalize() == 0xdcb27518fed9d577)
    }
}

private final class SinglePassBytes64: Sequence, IteratorProtocol {
    private let bytes: [UInt8]
    private var index = 0

    init(_ bytes: [UInt8]) { self.bytes = bytes }
    func makeIterator() -> SinglePassBytes64 { self }
    func next() -> UInt8? {
        guard index < bytes.count else { return nil }
        defer { index += 1 }
        return bytes[index]
    }
}
