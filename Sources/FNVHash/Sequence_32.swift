//
//  File.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

import Foundation

extension Sequence where Element == UInt8 {

    /// Computes the FNV1a-32 hash of this sequence of bytes.
    /// - Returns: The 32-bit FNV1a hash value
    public func fnv1a_32() -> UInt32 {
        var hash = fnv32OffsetBasis
        for byte in self {
            hash ^= UInt32(byte)
            hash = hash &* fnv32Prime
        }
        return hash
    }

    /// Computes the FNV1-32 hash of this sequence of bytes.
    /// - Returns: The 32-bit FNV1 hash value
    public func fnv1_32() -> UInt32 {
        var hash = fnv32OffsetBasis
        for byte in self {
            hash = hash &* fnv32Prime
            hash ^= UInt32(byte)
        }
        return hash
    }

}
