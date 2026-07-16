import Foundation
import Testing
@testable import FNVHash

@Suite("FNVHash input dispatch")
struct FNVHashInputDispatchTests {
    @Test("Contiguous collections use raw buffers")
    func contiguousCollectionsUseRawBuffers() {
        var arrayProbe = InputDispatchProbe()
        arrayProbe.update(data: [0x66, 0x6f, 0x6f])
        #expect(arrayProbe.byteUpdateCount == 0)
        #expect(arrayProbe.bufferUpdateCount == 1)
        #expect(arrayProbe.bytes == [0x66, 0x6f, 0x6f])

        var dataProbe = InputDispatchProbe()
        dataProbe.update(data: Data([0x62, 0x61, 0x72]))
        #expect(dataProbe.byteUpdateCount == 0)
        #expect(dataProbe.bufferUpdateCount == 1)
        #expect(dataProbe.bytes == [0x62, 0x61, 0x72])
    }

    @Test("Sequences use individual byte updates")
    func sequencesUseByteUpdates() {
        var probe = InputDispatchProbe()
        probe.update(data: SinglePassInput([0x66, 0x6f, 0x6f]))

        #expect(probe.byteUpdateCount == 3)
        #expect(probe.bufferUpdateCount == 0)
        #expect(probe.bytes == [0x66, 0x6f, 0x6f])
    }

    @Test("Non-contiguous collections fall back to individual byte updates")
    func nonContiguousCollectionsUseFallback() {
        let input = NonContiguousBytes([0x66, 0x6f, 0x6f])
        var probe = InputDispatchProbe()
        probe.update(data: input)

        #expect(probe.byteUpdateCount == 3)
        #expect(probe.bufferUpdateCount == 0)
        #expect(probe.bytes == [0x66, 0x6f, 0x6f])
        #expect(FNV1a.Hash32.hash(data: input) == 0xa9f37ed7)
    }
}

private struct InputDispatchProbe: FNVHash {
    private(set) var byteUpdateCount = 0
    private(set) var bufferUpdateCount = 0
    private(set) var bytes: [UInt8] = []

    init() {}

    mutating func update(byte: UInt8) {
        byteUpdateCount += 1
        bytes.append(byte)
    }

    mutating func update(bufferPointer: UnsafeRawBufferPointer) {
        bufferUpdateCount += 1
        bytes.append(contentsOf: bufferPointer)
    }

    consuming func finalize() -> UInt {
        UInt(bytes.count)
    }
}

private final class SinglePassInput: Sequence, IteratorProtocol {
    private let bytes: [UInt8]
    private var index = 0

    init(_ bytes: [UInt8]) { self.bytes = bytes }
    func makeIterator() -> SinglePassInput { self }

    func next() -> UInt8? {
        guard index < bytes.count else { return nil }
        defer { index += 1 }
        return bytes[index]
    }
}

private struct NonContiguousBytes: Collection {
    private let bytes: [UInt8]

    init(_ bytes: [UInt8]) { self.bytes = bytes }

    var startIndex: Int { bytes.startIndex }
    var endIndex: Int { bytes.endIndex }
    func index(after index: Int) -> Int { bytes.index(after: index) }
    subscript(index: Int) -> UInt8 { bytes[index] }

    func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<UInt8>) throws -> R
    ) rethrows -> R? {
        nil
    }
}
