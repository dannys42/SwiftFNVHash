import Foundation
import Testing
@testable import FNVCLI

private actor ActivityProbe {
    private var active = 0
    private var maximum = 0

    func started() {
        active += 1
        maximum = max(maximum, active)
    }

    func finished() {
        active -= 1
    }

    func maximumActivity() -> Int {
        maximum
    }
}

@Suite("FNV CLI")
struct FNVCLITests {
    @Test("all width and algorithm pairs dispatch")
    func allDispatchPairs() throws {
        let bytes = Data("hello".utf8)

        #expect(try FNVCLI.hash(data: bytes, bits: .bits32, algorithm: .fnv1) == "b6fa7167")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits32, algorithm: .fnv1a) == "4f9f2cab")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits64, algorithm: .fnv1) == "7b495389bdbdd4c7")
        #expect(try FNVCLI.hash(data: bytes, bits: .bits64, algorithm: .fnv1a) == "a430d84680aabd0b")

        if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *) {
            #expect(try FNVCLI.hash(data: bytes, bits: .bits128, algorithm: .fnv1) == "f14b58486483d94f708038798c29697f")
            #expect(try FNVCLI.hash(data: bytes, bits: .bits128, algorithm: .fnv1a) == "e3e1efd54283d94f7081314b599d31b3")
        }
    }

    @Test("hash result uses checksum-compatible display")
    func hashResultDescription() {
        let result = HashResult(index: 4, hashString: "00000001", filename: "input.bin")
        #expect(result.description == "00000001  input.bin")
    }

    @Test("file hashing bounds concurrency and preserves input order and duplicates")
    func boundedFileHashing() async throws {
        let filenames = ["zero", "duplicate", "two", "three", "duplicate", "five", "six", "seven", "eight", "nine"]
        let probe = ActivityProbe()

        let results = try await FNVCLI.hashFiles(
            filenames,
            bits: .bits64,
            algorithm: .fnv1a,
            maximumConcurrentTasks: 2
        ) { filename, index, _, _ in
            await probe.started()
            do {
                try await Task.sleep(for: .milliseconds((filenames.count - index) * 2))
                await probe.finished()
                return HashResult(index: index, hashString: "hash-\(index)", filename: filename)
            } catch {
                await probe.finished()
                throw error
            }
        }

        #expect(await probe.maximumActivity() == 2)
        #expect(results.map(\.index) == Array(filenames.indices))
        #expect(results.map(\.filename) == filenames)
        #expect(results[1].filename == results[4].filename)
        #expect(results[1].index != results[4].index)
    }

    @Test("file hashing rejects a nonpositive concurrency limit")
    func invalidConcurrencyLimit() async {
        do {
            _ = try await FNVCLI.hashFiles(
                ["input"],
                bits: .bits64,
                algorithm: .fnv1a,
                maximumConcurrentTasks: 0
            ) { _, _, _, _ in
                Issue.record("Operation must not run for an invalid limit")
                return HashResult(index: 0, hashString: "", filename: "")
            }
            Issue.record("Expected an invalid-limit error")
        } catch {
            #expect(error.localizedDescription.contains("greater than zero"))
        }
    }
}
