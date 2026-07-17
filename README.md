# FNVHash

A pure Swift implementation of the non-cryptographic Fowler–Noll–Vo hash functions for Apple platforms.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20Mac%20Catalyst%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com)

FNVHash provides FNV-1 and FNV-1a in 32-, 64-, and 128-bit forms. Its API follows the same one-shot and incremental shape as CryptoKit hash functions.

> [!WARNING]
> FNV is not a cryptographic hash. Do not use it where collision resistance, preimage resistance, authentication, signatures, or password storage are required.

## When to use FNV

FNV is appropriate when you need a small, inexpensive, reproducible hash for trusted or non-adversarial input. Common uses include deterministic partitioning or sharding, cache keys, persistent identifiers, hash tables whose inputs cannot be chosen by an attacker, deduplication prefilters, and checks for accidental data corruption.

Applications must still tolerate collisions. For example, compare the original values after a hash match. Use a cryptographic hash or an appropriate keyed hash when inputs may be attacker-controlled or when correctness, integrity, or security depends on collisions being infeasible.

## Requirements

- Swift 6.0 or newer
- macOS 15+, iOS 18+, tvOS 15+, watchOS 8+, Mac Catalyst 15+, or visionOS 1+

The 32- and 64-bit APIs support every deployment target above. Native `UInt128` requires Swift and OS runtime support, so `Hash128` requires macOS 15+, iOS 18+, tvOS 18+, watchOS 11+, Mac Catalyst 18+, or visionOS 2+.

## Installation

There is not yet a tagged release. Add the package's `main` branch to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dannys42/SwiftFNVHash.git", branch: "main")
]
```

Then add `FNVHash` to the dependencies of your target. In Xcode, use File → Add Package Dependencies, enter the same repository URL, and select the `main` branch.

## Usage

Use `FNV1` or `FNV1a` with the desired digest width. `hash(data:)` accepts byte sequences such as `Data`, `[UInt8]`, and `String.UTF8View`. `hash(string:)` hashes the string's UTF-8 bytes.

```swift
import Foundation
import FNVHash

let data = Data("Hello, World!".utf8)
let dataDigest: UInt64 = FNV1a.Hash64.hash(data: data)
let stringDigest: UInt64 = FNV1a.Hash64.hash(string: "Hello, World!")
```

For incremental hashing, update with any number of byte chunks and finalize once:

```swift
import FNVHash

let firstChunk = Array("Hello, ".utf8)
let secondChunk = Array("World!".utf8)

var hasher = FNV1a.Hash64()
hasher.update(data: firstChunk)
hasher.update(data: secondChunk)
let digest: UInt64 = hasher.finalize()
```

After calling `finalize()`, create a new hasher before processing more input.

The six concrete hash types are:

| Variant | 32-bit | 64-bit | 128-bit |
| --- | --- | --- | --- |
| FNV-1 (multiply, then XOR) | `FNV1.Hash32` | `FNV1.Hash64` | `FNV1.Hash128` |
| FNV-1a (XOR, then multiply) | `FNV1a.Hash32` | `FNV1a.Hash64` | `FNV1a.Hash128` |

Guard `Hash128` calls with an availability check:

```swift
import FNVHash

if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *) {
    let digest: UInt128 = FNV1a.Hash128.hash(string: "Hello, World!")
    print(digest)
}
```

FNV-1a generally distributes some input patterns better than FNV-1, but neither variant provides cryptographic security.

## Command-line tool

The `fnv` executable hashes one or more files. File paths are positional arguments:

```bash
swift run fnv README.md
swift run fnv --bits 32 --algorithm fnv1 README.md
swift run fnv --bits 128 --algorithm fnv1a README.md LICENSE
```

Options:

- `-b, --bits <32|64|128>` selects the digest width; the default is `64`.
- `-a, --algorithm <fnv1|fnv1a>` selects the variant; the default is `fnv1a`.

Files are hashed concurrently with a bounded number of tasks. Results retain the input order, including repeated paths, and use checksum-compatible output: a fixed-width lowercase hexadecimal digest, two spaces, and the original path.

## References

- [RFC 9923: The FNV Non-Cryptographic Hash Algorithm](https://www.rfc-editor.org/info/rfc9923)
- [Reference FNV repository](https://github.com/lcn2/fnv)

## License

This project is licensed under the terms in [LICENSE](LICENSE).
