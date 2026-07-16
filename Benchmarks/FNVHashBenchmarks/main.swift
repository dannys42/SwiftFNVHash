import Foundation
import FNVHash

private struct SinglePassBytes: Sequence {
    let bytes: [UInt8]

    func makeIterator() -> IndexingIterator<[UInt8]> {
        bytes.makeIterator()
    }
}

struct Measurement {
    let name: String
    let byteCount: Int
    let seconds: Double
    let checksum: UInt64

    var gibibytesPerSecond: Double {
        Double(byteCount) / seconds / Double(1 << 30)
    }
}

private let iterationCount = 5
private let minimumStreamingGiBPerSecond = 0.120
private let minimumStreamingToOneShotRatio = 0.85

private func seconds(_ duration: Duration) -> Double {
    let components = duration.components
    return Double(components.seconds) + Double(components.attoseconds) / 1e18
}

private func measure(
    name: String,
    byteCount: Int,
    operation: () -> UInt64
) -> Measurement {
    _ = operation()

    var samples: [Double] = []
    var checksum: UInt64 = 0
    samples.reserveCapacity(iterationCount)

    for _ in 0..<iterationCount {
        let clock = ContinuousClock()
        let start = clock.now
        let digest = operation()
        samples.append(seconds(start.duration(to: clock.now)))
        checksum ^= digest
    }

    samples.sort()
    return Measurement(
        name: name,
        byteCount: byteCount,
        seconds: samples[samples.count / 2],
        checksum: checksum
    )
}

private let dataSize = 32 * 1_024 * 1_024
private var input = Data(count: dataSize)
input.withUnsafeMutableBytes { rawBuffer in
    for index in rawBuffer.indices {
        rawBuffer[index] = UInt8(truncatingIfNeeded: index &* 31 &+ 17)
    }
}
private let sequenceInput = Array(input)

let oneShot = measure(name: "static Data", byteCount: input.count) {
    FNV1a.Hash64.hash(data: input)
}
let incremental = measure(name: "incremental Data", byteCount: input.count) {
    var hasher = FNV1a.Hash64()
    hasher.update(data: input)
    return hasher.finalize()
}
let singlePass = measure(name: "single-pass Sequence", byteCount: input.count) {
    FNV1a.Hash64.hash(data: SinglePassBytes(bytes: sequenceInput))
}

let directByteCount = 2_000_000
let directByte = measure(name: "direct byte updates", byteCount: directByteCount) {
    var hasher = FNV1a.Hash64()
    for index in 0..<directByteCount {
        hasher.update(byte: UInt8(truncatingIfNeeded: index))
    }
    return hasher.finalize()
}

let measurements = [oneShot, incremental, singlePass, directByte]
print("FNV-1a 64-bit release benchmark (median of \(iterationCount) iterations)")
for measurement in measurements {
    print(String(
        format: "%-22s %7.3f GiB/s  %8.3f ms  checksum %016llx",
        (measurement.name as NSString).utf8String!,
        measurement.gibibytesPerSecond,
        measurement.seconds * 1_000,
        measurement.checksum
    ))
}

guard measurements.allSatisfy({ $0.checksum != 0 }) else {
    fatalError("benchmark produced a zero checksum")
}
guard incremental.gibibytesPerSecond >= minimumStreamingGiBPerSecond else {
    fatalError("streaming throughput below required baseline")
}
guard incremental.gibibytesPerSecond >= oneShot.gibibytesPerSecond * minimumStreamingToOneShotRatio else {
    fatalError("incremental contiguous hashing is materially slower than one-shot hashing")
}
