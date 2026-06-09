//
//  FNVHash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/8/26.
//

// MARK: - Constants

private let fnv1a64OffsetBasis: UInt64 = 0xcbf29ce484222325
private let fnv1a64Prime: UInt64 = 0x100000001b3

// MARK: - Core Function

/// Computes the FNV1a-64 hash of a sequence of bytes.
/// - Parameter bytes: A sequence of UInt8 bytes
/// - Returns: The 64-bit FNV1a hash value
public func fnv1a_64<S: Sequence>(_ bytes: S) -> UInt64 where S.Element == UInt8 {
    var hash = fnv1a64OffsetBasis
    for byte in bytes {
        hash ^= UInt64(byte)
        hash = hash &* fnv1a64Prime
    }
    return hash
}

// MARK: - String Extension

extension String {
    /// Computes the FNV1a-64 hash of the string's UTF-8 representation.
    /// - Returns: The 64-bit FNV1a hash value
    public func fnv1a_64() -> UInt64 {
        return FNVHash.fnv1a_64(self.utf8)
    }
}
