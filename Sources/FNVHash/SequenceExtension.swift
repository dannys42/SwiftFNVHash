//
//  FNVHash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/8/26.
//

// MARK: - Constants

private let fnv64OffsetBasis: UInt64 = 0xcbf29ce484222325
private let fnv64Prime: UInt64 = 0x100000001b3

// MARK: - Sequence Extension

extension Sequence where Element == UInt8 {
    /// Computes the FNV1a-64 hash of this sequence of bytes.
    /// - Returns: The 64-bit FNV1a hash value
    public func fnv1a_64() -> UInt64 {
        var hash = fnv64OffsetBasis
        for byte in self {
            hash ^= UInt64(byte)
            hash = hash &* fnv64Prime
        }
        return hash
    }
}
