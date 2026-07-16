import Foundation
import Testing
@testable import FNVHash

@Suite("FNV32Tests")
struct FNV32Tests {
    /// FNV-1 values from the pinned upstream test vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1Strings: [(String, UInt32)] = [
        ("", 0x811c9dc5),
        ("foo", 0x408f5e13),
        ("chongo was here!\n", 0xdd002f35),
        ("hello", 0xb6fa7167),
    ]

    /// FNV-1a values standardized by RFC 9923 and present in the pinned upstream vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1aStrings: [(String, UInt32)] = [
        ("", 0x811c9dc5),
        ("foo", 0xa9f37ed7),
        ("chongo was here!\n", 0xd49930d5),
        ("hello", 0x4f9f2cab),
    ]

    /// FNV-1 values from the pinned upstream test vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1Bytes: [([UInt8], UInt32)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xb78320a1), ([0x01, 0x00, 0x00, 0xff], 0x0caf4135),
        ([0xff, 0x00, 0x00, 0x02], 0xb78320a2), ([0x02, 0x00, 0x00, 0xff], 0xcdc88e80),
        ([0xff, 0x00, 0x00, 0x03], 0xb78320a3), ([0x03, 0x00, 0x00, 0xff], 0x8ee1dbcb),
        ([0xff, 0x00, 0x00, 0x04], 0xb78320a4), ([0x04, 0x00, 0x00, 0xff], 0x4ffb2716),
        ([0x40, 0x51, 0x4e, 0x44], 0x860632aa), ([0x44, 0x4e, 0x51, 0x40], 0xcc2c5c64),
        ([0x40, 0x51, 0x4e, 0x4a], 0x860632a4), ([0x4a, 0x4e, 0x51, 0x40], 0x2a7ec4a6),
        ([0x40, 0x51, 0x4e, 0x54], 0x860632ba),
    ]

    /// FNV-1a values standardized by RFC 9923 and present in the pinned upstream vectors:
    /// https://github.com/lcn2/fnv/blob/6f5d7fa29f92987311223e71ecf8b13f7c5551f2/test_fnv.c
    private static let fnv1aBytes: [([UInt8], UInt32)] = [
        ([0xff, 0x00, 0x00, 0x01], 0xc48fb86d), ([0x01, 0x00, 0x00, 0xff], 0x2269f369),
        ([0xff, 0x00, 0x00, 0x02], 0xc18fb3b4), ([0x02, 0x00, 0x00, 0xff], 0x50ef1236),
        ([0xff, 0x00, 0x00, 0x03], 0xc28fb547), ([0x03, 0x00, 0x00, 0xff], 0x96c3bf47),
        ([0xff, 0x00, 0x00, 0x04], 0xbf8fb08e), ([0x04, 0x00, 0x00, 0xff], 0xf3e4d49c),
        ([0x40, 0x51, 0x4e, 0x44], 0x32179058), ([0x44, 0x4e, 0x51, 0x40], 0x280bfee6),
        ([0x40, 0x51, 0x4e, 0x4a], 0x30178d32), ([0x4a, 0x4e, 0x51, 0x40], 0x21addaf8),
        ([0x40, 0x51, 0x4e, 0x54], 0x4217a988),
    ]

    @Test("Trusted FNV-1 vectors")
    func fnv1Vectors() {
        for (string, expected) in Self.fnv1Strings {
            #expect(FNV1.Hash32.hash(string: string) == expected)
        }
        for (bytes, expected) in Self.fnv1Bytes {
            #expect(FNV1.Hash32.hash(data: bytes) == expected)
            #expect(FNV1.Hash32.hash(data: Data(bytes)) == expected)
        }
    }

    @Test("Trusted FNV-1a vectors")
    func fnv1aVectors() {
        for (string, expected) in Self.fnv1aStrings {
            #expect(FNV1a.Hash32.hash(string: string) == expected)
        }
        for (bytes, expected) in Self.fnv1aBytes {
            #expect(FNV1a.Hash32.hash(data: bytes) == expected)
            #expect(FNV1a.Hash32.hash(data: Data(bytes)) == expected)
        }
    }

    @Test("One-shot APIs accept Data, arrays, UTF-8 views, and single-pass sequences")
    func oneShotAPIs() {
        let bytes = Array("foo".utf8)
        #expect(FNV1.Hash32.hash(data: Data(bytes)) == 0x408f5e13)
        #expect(FNV1a.Hash32.hash(data: bytes) == 0xa9f37ed7)
        #expect(FNV1.Hash32.hash(data: "foo".utf8) == 0x408f5e13)
        #expect(FNV1a.Hash32.hash(data: SinglePassBytes(bytes)) == 0xa9f37ed7)
    }

    @Test("Incremental APIs support bytes and split chunks")
    func incrementalAPIs() {
        var fnv1 = FNV1.Hash32()
        fnv1.update(byte: 0x66)
        fnv1.update(data: [0x6f])
        fnv1.update(data: Data([0x6f]))
        #expect(fnv1.finalize() == 0x408f5e13)

        var fnv1a = FNV1a.Hash32()
        fnv1a.update(data: "f".utf8)
        fnv1a.update(byte: 0x6f)
        fnv1a.update(data: SinglePassBytes([0x6f]))
        #expect(fnv1a.finalize() == 0xa9f37ed7)
    }
}

private final class SinglePassBytes: Sequence, IteratorProtocol {
    private let bytes: [UInt8]
    private var index = 0

    init(_ bytes: [UInt8]) { self.bytes = bytes }
    func makeIterator() -> SinglePassBytes { self }
    func next() -> UInt8? {
        guard index < bytes.count else { return nil }
        defer { index += 1 }
        return bytes[index]
    }
}
