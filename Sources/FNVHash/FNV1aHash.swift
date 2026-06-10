//
//  FNV1aHash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

/// A Fowler-Noll-Vo (FNV-1a) hash function implementation.
///
/// FNV-1a is a non-cryptographic hash function designed for fast hashing while
/// maintaining good distribution properties. The FNV-1a variant XORs with the
/// byte value before multiplying by the prime, which provides better avalanche
/// characteristics than FNV-1.
///
/// ## Algorithm
///
/// The FNV-1a algorithm processes each byte as follows:
/// 1. XOR the hash with the byte value
/// 2. Multiply the hash by the FNV prime
///
/// ## Usage
///
/// Create an instance with the desired hash size, add data using ``combine(_:)``,
/// then retrieve the final hash with ``finalize()``:
///
/// ```swift
/// var hasher = FNV1aHash<UInt32>()
/// hasher.combine("Hello, World!")
/// let hash = hasher.finalize()
/// ```
///
/// ## Supported Hash Sizes
///
/// - `UInt32`: 32-bit FNV-1a hash
/// - `UInt64`: 64-bit FNV-1a hash
///
/// ## Topics
///
/// ### Creating a Hasher
///
/// - ``init()``
///
/// ### Adding Data
///
/// - ``combine(_:)``
/// - ``combine(_:)-5hj8k``
///
/// ### Getting the Result
///
/// - ``finalize()``
public struct FNV1aHash<HashType: UnsignedInteger & FixedWidthInteger & Numeric & AdditiveArithmetic>: FNVHash {
    private var hash: HashType
    private let offset: HashType
    private let prime: HashType

    /// Incorporates a single byte into the hash computation.
    ///
    /// - Parameter value: The byte value to hash.
    public mutating func combine(_ value: UInt8) {
        self.combine([value])
    }

    /// Incorporates a sequence of bytes into the hash computation.
    ///
    /// This method processes each byte in the sequence using the FNV-1a algorithm:
    /// XOR with the byte value, then multiply by the prime.
    ///
    /// - Parameter sequence: A sequence of `UInt8` values to hash.
    public mutating func combine(_ sequence: some Sequence<UInt8>) {
        for byte in sequence {
            hash ^= HashType(byte)
            hash = hash &* prime
        }
    }

    /// Finalizes the hash computation and returns the hash value.
    ///
    /// After calling this method, the hash state is consumed. To compute another hash,
    /// create a new instance.
    ///
    /// - Returns: The computed FNV-1a hash value.
    public mutating func finalize() -> HashType {
        return hash
    }
}

public extension FNV1aHash where HashType == UInt32 {
    /// Creates a new 32-bit FNV-1a hasher initialized with the standard offset basis.
    ///
    /// The hasher is ready to accept data via ``combine(_:)`` calls.
    init() {
        self.offset = fnv32OffsetBasis
        self.prime = fnv32Prime

        self.hash = offset
    }
}

public extension FNV1aHash where HashType == UInt64 {
    /// Creates a new 64-bit FNV-1a hasher initialized with the standard offset basis.
    ///
    /// The hasher is ready to accept data via ``combine(_:)`` calls.
    init() {
        self.offset = fnv64OffsetBasis
        self.prime = fnv64Prime

        self.hash = offset
    }
}
