import ArgumentParser
import Foundation
import FNVHash
import Utilities

enum BitSize: String, CaseIterable, Decodable, ExpressibleByArgument {
    case bits32 = "32"
    case bits64 = "64"
}
enum Algorithm: String, CaseIterable, Decodable, ExpressibleByArgument {
    case fnv1a
    case fnv1
}

@main
struct FNVHashMain: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Compute FNV hash values for files"
    )

    @Option(name: .shortAndLong, help: "Hash bit size: 32 or 64")
    var bits = BitSize.bits64

    @Option(name: .shortAndLong, help: "Algorithm: fnv1a or fnv1")
    var algorithm = Algorithm.fnv1a

    @Argument(help: "One or more files to hash")
    var files: [String]

    mutating func run() async throws {

        // Process files concurrently if multiple
        if files.count == 1 {
            let result = try Self.hashFile(files[0], bits: bits, algorithm: algorithm)
            print(result)
        } else {
            try await withThrowingTaskGroup(of: HashResult.self) { group in
                for file in files {
                    let bits = bits
                    let algorithm = algorithm
                    group.addTask {
                        let result = try Self.hashFile(file, bits: bits, algorithm: algorithm)
                        return result
                    }
                }

                // Collect results and maintain order
                var results: [String: HashResult] = [:]
                for try await result in group {
                    results[result.filename] = result
                }

                // Print in original order
                for file in files {
                    if let result = results[file] {
                        print(result)
                    }
                }
            }
        }
    }

    struct HashResult: CustomStringConvertible {
        let hashData: Data
        let hashString: String
        let filename: String

        var description: String {
            "\(hashString)  \(filename)"
        }

    }
    private static func hashFile(_ filename: String, bits: BitSize, algorithm: Algorithm) throws -> HashResult {

        let fileURL = URL(fileURLWithPath: filename)
        let inputData = try Data(contentsOf: fileURL, options: .mappedIfSafe)

        var hasher = self.hasher(bits: bits, algorithm: algorithm)

        hasher.combine(inputData)
        let value = hasher.finalize()
        let hexString = value.asHexString
        let valueData = withUnsafeBytes(of: value) { Data($0) }

        return HashResult(hashData: valueData,
                          hashString: hexString,
                          filename: filename)
    }

    private static func hasher(bits: BitSize, algorithm: Algorithm) -> any FNVHash {
        switch (bits, algorithm) {
        case (.bits32, .fnv1):  return FNV1Hash<UInt32>()
        case (.bits32, .fnv1a): return FNV1aHash<UInt32>()
        case (.bits64, .fnv1):  return FNV1Hash<UInt64>()
        case (.bits64, .fnv1a): return FNV1aHash<UInt64>()
        }

    }
}
