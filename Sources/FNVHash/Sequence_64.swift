//
//  File.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

import Foundation

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

    /// Computes the FNV1-64 hash of this sequence of bytes.
    /// - Returns: The 64-bit FNV1 hash value
    public func fnv1_64() -> UInt64 {
        var hash = fnv64OffsetBasis
        for byte in self {
            hash = hash &* fnv64Prime
            hash ^= UInt64(byte)
        }
        return hash
    }

}

