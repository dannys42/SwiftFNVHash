import Foundation
import FNVHash
import Utilities

package enum BitSize: String, CaseIterable, Sendable {
    case bits32 = "32"
    case bits64 = "64"
    case bits128 = "128"
}

package enum Algorithm: String, CaseIterable, Sendable {
    case fnv1
    case fnv1a
}

package struct HashResult: CustomStringConvertible, Sendable {
    package let index: Int
    package let hashString: String
    package let filename: String

    package init(index: Int, hashString: String, filename: String) {
        self.index = index
        self.hashString = hashString
        self.filename = filename
    }

    package var description: String {
        "\(hashString)  \(filename)"
    }
}

private struct IndexedHashResult: Sendable {
    let index: Int
    let result: HashResult
}

package enum FNVCLI {
    package static func hash(data: Data, bits: BitSize, algorithm: Algorithm) throws -> String {
        switch (bits, algorithm) {
        case (.bits32, .fnv1):
            FNV1.Hash32.hash(data: data).asHexString
        case (.bits32, .fnv1a):
            FNV1a.Hash32.hash(data: data).asHexString
        case (.bits64, .fnv1):
            FNV1.Hash64.hash(data: data).asHexString
        case (.bits64, .fnv1a):
            FNV1a.Hash64.hash(data: data).asHexString
        case (.bits128, let algorithm):
            try hash128(data: data, algorithm: algorithm)
        }
    }

    package static func hashFile(
        _ filename: String,
        index: Int,
        bits: BitSize,
        algorithm: Algorithm
    ) throws -> HashResult {
        let fileURL = URL(fileURLWithPath: filename)
        let inputData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        return try HashResult(
            index: index,
            hashString: hash(data: inputData, bits: bits, algorithm: algorithm),
            filename: filename
        )
    }

    package static func hashFiles(
        _ filenames: [String],
        bits: BitSize,
        algorithm: Algorithm
    ) async throws -> [HashResult] {
        try await hashFiles(
            filenames,
            bits: bits,
            algorithm: algorithm,
            maximumConcurrentTasks: max(1, ProcessInfo.processInfo.activeProcessorCount)
        ) { filename, index, bits, algorithm in
            try hashFile(filename, index: index, bits: bits, algorithm: algorithm)
        }
    }

    package static func hashFiles(
        _ filenames: [String],
        bits: BitSize,
        algorithm: Algorithm,
        maximumConcurrentTasks: Int,
        operation: @escaping @Sendable (String, Int, BitSize, Algorithm) async throws -> HashResult
    ) async throws -> [HashResult] {
        guard maximumConcurrentTasks > 0 else {
            throw FNVCLIError.invalidMaximumConcurrentTasks(maximumConcurrentTasks)
        }

        return try await withThrowingTaskGroup(of: IndexedHashResult.self) { group in
            var nextIndex = 0
            let initialTaskCount = min(maximumConcurrentTasks, filenames.count)

            for _ in 0..<initialTaskCount {
                let index = nextIndex
                let filename = filenames[index]
                nextIndex += 1
                group.addTask {
                    try Task.checkCancellation()
                    let result = try await operation(filename, index, bits, algorithm)
                    return IndexedHashResult(index: index, result: result)
                }
            }

            var indexedResults: [IndexedHashResult] = []
            indexedResults.reserveCapacity(filenames.count)

            while let completed = try await group.next() {
                indexedResults.append(completed)

                if nextIndex < filenames.count {
                    let index = nextIndex
                    let filename = filenames[index]
                    nextIndex += 1
                    group.addTask {
                        try Task.checkCancellation()
                        let result = try await operation(filename, index, bits, algorithm)
                        return IndexedHashResult(index: index, result: result)
                    }
                }
            }

            return indexedResults.sorted { $0.index < $1.index }.map(\.result)
        }
    }

    private static func hash128(data: Data, algorithm: Algorithm) throws -> String {
        guard #available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *) else {
            throw FNVCLIError.hash128Unavailable
        }

        switch algorithm {
        case .fnv1:
            return FNV1.Hash128.hash(data: data).asHexString
        case .fnv1a:
            return FNV1a.Hash128.hash(data: data).asHexString
        }
    }
}

private enum FNVCLIError: LocalizedError {
    case hash128Unavailable
    case invalidMaximumConcurrentTasks(Int)

    var errorDescription: String? {
        switch self {
        case .hash128Unavailable:
            "128-bit FNV hashing requires macOS 15, iOS 18, tvOS 18, watchOS 11, Mac Catalyst 18, or visionOS 2."
        case .invalidMaximumConcurrentTasks(let limit):
            "Maximum concurrent tasks must be greater than zero; received \(limit)."
        }
    }
}
