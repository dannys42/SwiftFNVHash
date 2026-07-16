import ArgumentParser
import FNVCLI

private enum CLIBitSize: String, CaseIterable, Decodable, ExpressibleByArgument {
    case bits32 = "32"
    case bits64 = "64"
    case bits128 = "128"

    var supportValue: BitSize {
        switch self {
        case .bits32: .bits32
        case .bits64: .bits64
        case .bits128: .bits128
        }
    }
}

private enum CLIAlgorithm: String, CaseIterable, Decodable, ExpressibleByArgument {
    case fnv1
    case fnv1a

    var supportValue: Algorithm {
        switch self {
        case .fnv1: .fnv1
        case .fnv1a: .fnv1a
        }
    }
}

@main
struct FNVHashMain: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Compute FNV hash values for files"
    )

    @Option(name: .shortAndLong, help: "Hash bit size: 32, 64, or 128")
    private var bits = CLIBitSize.bits64

    @Option(name: .shortAndLong, help: "Algorithm: fnv1 or fnv1a")
    private var algorithm = CLIAlgorithm.fnv1a

    @Argument(help: "One or more files to hash")
    private var files: [String]

    mutating func run() async throws {
        for (index, file) in files.enumerated() {
            let result = try FNVCLI.hashFile(
                file,
                index: index,
                bits: bits.supportValue,
                algorithm: algorithm.supportValue
            )
            print(result)
        }
    }
}
