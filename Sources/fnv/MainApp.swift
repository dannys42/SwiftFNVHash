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
            try await withThrowingTaskGroup(of: (String, String).self) { group in
                for file in files {
                    let bits = bits
                    let algorithm = algorithm
                    group.addTask {
                        let result = try Self.hashFile(file, bits: bits, algorithm: algorithm)
                        return (file, result)
                    }
                }

                // Collect results and maintain order
                var results: [String: String] = [:]
                for try await (_, result) in group {
                    // Extract filename from result (format: "hash  filename")
                    let parts = result.split(separator: "  ", maxSplits: 1)
                    if parts.count == 2 {
                        let filename = String(parts[1])
                        results[filename] = result
                    }
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

    private static func hashFile(_ filename: String, bits: BitSize, algorithm: Algorithm) throws -> String {
        let fileURL = URL(fileURLWithPath: filename)
        let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)

        var hasher = self.hasher(bits: bits, algorithm: algorithm)

        hasher.combine(data)
        let value = hasher.finalize()
        let hexString = value.asHexString

        return "\(hexString)  \(filename)"
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
