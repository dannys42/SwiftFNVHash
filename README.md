# FNVHash

A Swift implementation of the Fowler-Noll-Vo (FNV) hash function for iOS, macOS, tvOS, watchOS, and visionOS.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com)

## Overview

FNVHash provides a pure Swift implementation of the FNV non-cryptographic hash function. FNV is designed to be fast while maintaining excellent collision resistance, making it ideal for hash tables, data fingerprinting, and checksums.

This package supports both FNV-1 and FNV-1a variants in 32-bit, and 64-bit configurations.

## Requirements

- Swift 6.0+
- iOS 18+ / macOS 15+ / tvOS 15+ / watchOS 8+ / visionOS 1+

## Installation

### Swift Package Manager

Add FNVHash to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SwiftFNVHash.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the version and add to your target

## Usage

### Hashing Strings

```swift
import FNVHash

let text = "Hello, World!"

// FNV-1a variants (recommended)
let hash32 = text.fnv1a_32()      // UInt32
let hash64 = text.fnv1a_64()      // UInt64

// FNV-1 variants
let hash1_32 = text.fnv1_32()     // UInt32
let hash1_64 = text.fnv1_64()     // UInt64
```

### Hashing Byte Sequences

```swift
import FNVHash

let data = "Hello, World!".utf8

// FNV-1a variants
let hash32 = data.fnv1a_32()      // UInt32
let hash64 = data.fnv1a_64()      // UInt64

// FNV-1 variants
let hash1_32 = data.fnv1_32()     // UInt32
let hash1_64 = data.fnv1_64()     // UInt64
```

### Command Line Tool

The package includes a command-line utility for computing FNV hashes:

```bash
# Hash a string
fnv "Hello, World!"

# Hash file contents
fnv --file myfile.txt
```

## API Reference

### String Extensions

| Method | Return Type | Description |
|--------|-------------|-------------|
| `fnv1a_32()` | `UInt32` | FNV-1a 32-bit hash |
| `fnv1_32()` | `UInt32` | FNV-1 32-bit hash |
| `fnv1a_64()` | `UInt64` | FNV-1a 64-bit hash |
| `fnv1_64()` | `UInt64` | FNV-1 64-bit hash |
| `fnv1a_128()` | `UInt128` | FNV-1a 128-bit hash |
| `fnv1_128()` | `UInt128` | FNV-1 128-bit hash |

### Sequence<UInt8> Extensions

All methods above are also available on any `Sequence` where `Element == UInt8`, including `Array<UInt8>`, `Data`, and `String.UTF8View`.

## FNV-1 vs FNV-1a

The FNV-1a variant (XOR then multiply) is generally recommended over FNV-1 (multiply then XOR) because it provides better avalanche characteristics and distribution for certain input patterns.

## References

- [Official FNV GitHub Repository](https://github.com/lcn2/fnv)
- [Official FNV Homepage](http://www.isthe.com/chongo/tech/comp/fnv/index.html)
- [RFC-9923](https://www.rfc-editor.org/info/rfc9923/)
- [Wikipedia: Fowler–Noll–Vo hash function](https://en.wikipedia.org/wiki/Fowler–Noll–Vo_hash_function)

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
