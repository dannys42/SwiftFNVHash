//
//  FNV1Hash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

/// A Fowler-Noll-Vo (FNV-1) hash function implementation.
///
/// FNV-1 is a non-cryptographic hash function designed for fast hashing while
/// maintaining good distribution properties. The FNV-1 variant multiplies by
/// the prime before XORing with the byte value.
///
/// ## Algorithm
///
/// The FNV-1 algorithm processes each byte as follows:
/// 1. Multiply the hash by the FNV prime
/// 2. XOR the hash with the byte value
///
/// ## Usage
///
/// Create an instance with the desired hash size, add data using ``combine(_:)``,
/// then retrieve the final hash with ``finalize()``:
///
/// ```swift
/// var hasher = FNV1Hash<UInt32>()
/// hasher.combine("Hello, World!")
/// let hash = hasher.finalize()
/// ```
///
/// ## Supported Hash Sizes
///
/// - `UInt32`: 32-bit FNV-1 hash
/// - `UInt64`: 64-bit FNV-1 hash
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
///
/// #### Excerpt from [RFC9923](https://www.rfc-editor.org/info/rfc9923/)
/// Operational experience indicates better hash dispersion for small amounts of data with FNV-1a. FNV-1a is suggested for general use.
///  - ``FNV1aHash``
///
public struct FNV1Hash<HashType: UnsignedInteger & FixedWidthInteger & Numeric & AdditiveArithmetic>: FNVHash {
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
    /// This method processes each byte in the sequence using the FNV-1 algorithm:
    /// multiply by the prime, then XOR with the byte value.
    ///
    /// - Parameter sequence: A sequence of `UInt8` values to hash.
    public mutating func combine(_ sequence: some Sequence<UInt8>) {
        for byte in sequence {
            hash = hash &* prime
            hash ^= HashType(byte)
        }
    }

    /// Finalizes the hash computation and returns the hash value.
    ///
    /// After calling this method, the hash state is consumed. To compute another hash,
    /// create a new instance.
    ///
    /// - Returns: The computed FNV-1 hash value.
    public mutating func finalize() -> HashType {
        return hash
    }
}

public extension FNV1Hash where HashType == UInt32 {
    /// Creates a new 32-bit FNV-1 hasher initialized with the standard offset basis.
    ///
    /// The hasher is ready to accept data via ``combine(_:)`` calls.
    init() {
        self.offset = fnv32OffsetBasis
        self.prime = fnv32Prime

        self.hash = offset
    }
}

public extension FNV1Hash where HashType == UInt64 {
    /// Creates a new 64-bit FNV-1 hasher initialized with the standard offset basis.
    ///
    /// The hasher is ready to accept data via ``combine(_:)`` calls.
    init() {
        self.offset = fnv64OffsetBasis
        self.prime = fnv64Prime

        self.hash = offset
    }
}
