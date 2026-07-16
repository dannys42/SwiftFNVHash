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

    var errorDescription: String? {
        "128-bit FNV hashing requires macOS 15, iOS 18, tvOS 18, watchOS 11, Mac Catalyst 18, or visionOS 2."
    }
}
