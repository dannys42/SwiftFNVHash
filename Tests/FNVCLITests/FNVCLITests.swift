import Foundation
import Testing
@testable import FNVCLI

private actor OperationGate {
    private struct StartWaiter {
        let indices: Set<Int>
        let continuation: CheckedContinuation<Void, Never>
    }

    private var active = 0
    private var maximum = 0
    private var startedIndices: Set<Int> = []
    private var startWaiters: [StartWaiter] = []
    private var releaseContinuations: [Int: CheckedContinuation<Void, Never>] = [:]

    func startAndWait(index: Int) async {
        active += 1
        maximum = max(maximum, active)
        startedIndices.insert(index)

        var remainingWaiters: [StartWaiter] = []
        for waiter in startWaiters {
            if waiter.indices.isSubset(of: startedIndices) {
                waiter.continuation.resume()
            } else {
                remainingWaiters.append(waiter)
            }
        }
        startWaiters = remainingWaiters

        await withCheckedContinuation { continuation in
            releaseContinuations[index] = continuation
        }
        active -= 1
    }

    func waitUntilStarted(_ indices: Set<Int>) async {
        guard !indices.isSubset(of: startedIndices) else { return }

        await withCheckedContinuation { continuation in
            startWaiters.append(StartWaiter(indices: indices, continuation: continuation))
        }
    }

    func release(_ index: Int) {
        let continuation = releaseContinuations.removeValue(forKey: index)
        precondition(continuation != nil, "Operation \(index) must be waiting before release")
        continuation?.resume()
    }

    func maximumActivity() -> Int {
        maximum
    }
}

private enum ExpectedOperationError: Error {
    case failed
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
        let filenames = ["duplicate", "one", "two", "duplicate"]
        let gate = OperationGate()

        let hashingTask = Task {
            try await FNVCLI.hashFiles(
                filenames,
                bits: .bits64,
                algorithm: .fnv1a,
                maximumConcurrentTasks: 2
            ) { filename, index, _, _ in
                await gate.startAndWait(index: index)
                return HashResult(index: index, hashString: "hash-\(index)", filename: filename)
            }
        }

        await gate.waitUntilStarted([0, 1])
        await gate.release(1)
        await gate.waitUntilStarted([2])
        await gate.release(2)
        await gate.waitUntilStarted([3])
        await gate.release(3)
        await gate.release(0)

        let results = try await hashingTask.value
        #expect(await gate.maximumActivity() == 2)
        #expect(results.map(\.index) == Array(filenames.indices))
        #expect(results.map(\.filename) == filenames)
        #expect(results[0].filename == results[3].filename)
        #expect(results[0].index != results[3].index)
    }

    @Test("file hashing throws cancellation after an operation ignores cancellation")
    func cancellationAfterOperationReturns() async {
        let gate = OperationGate()
        let hashingTask = Task {
            try await FNVCLI.hashFiles(
                ["input"],
                bits: .bits64,
                algorithm: .fnv1a,
                maximumConcurrentTasks: 1
            ) { filename, index, _, _ in
                await gate.startAndWait(index: index)
                return HashResult(index: index, hashString: "hash", filename: filename)
            }
        }

        await gate.waitUntilStarted([0])
        hashingTask.cancel()
        await gate.release(0)

        do {
            _ = try await hashingTask.value
            Issue.record("Expected cancellation to be propagated")
        } catch is CancellationError {
            // Expected.
        } catch {
            Issue.record("Expected CancellationError, received \(error)")
        }
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

    @Test("empty file input returns without invoking the operation")
    func emptyFileInput() async throws {
        let results = try await FNVCLI.hashFiles(
            [],
            bits: .bits64,
            algorithm: .fnv1a,
            maximumConcurrentTasks: 4
        ) { _, _, _, _ in
            Issue.record("Operation must not run for empty input")
            return HashResult(index: 0, hashString: "", filename: "")
        }

        #expect(results.isEmpty)
    }

    @Test("operation errors are propagated")
    func operationErrorPropagation() async {
        do {
            _ = try await FNVCLI.hashFiles(
                ["input"],
                bits: .bits64,
                algorithm: .fnv1a,
                maximumConcurrentTasks: 1
            ) { _, _, _, _ in
                throw ExpectedOperationError.failed
            }
            Issue.record("Expected the operation error")
        } catch ExpectedOperationError.failed {
            // Expected.
        } catch {
            Issue.record("Expected operation error, received \(error)")
        }
    }

    @Test("a concurrency limit larger than the input starts only input-count operations")
    func concurrencyLimitLargerThanInput() async throws {
        let filenames = ["zero", "one"]
        let gate = OperationGate()
        let hashingTask = Task {
            try await FNVCLI.hashFiles(
                filenames,
                bits: .bits64,
                algorithm: .fnv1a,
                maximumConcurrentTasks: 100
            ) { filename, index, _, _ in
                await gate.startAndWait(index: index)
                return HashResult(index: index, hashString: "hash", filename: filename)
            }
        }

        await gate.waitUntilStarted([0, 1])
        await gate.release(0)
        await gate.release(1)

        let results = try await hashingTask.value
        #expect(results.map(\.filename) == filenames)
        #expect(await gate.maximumActivity() == filenames.count)
    }
}
