//
//  StringExtensions.swift
//  FNVHash
//
//  Created by Danny Sung on 6/8/26.
//

import Foundation

extension String {
    /// Computes the FNV1a-32 hash of the string's UTF-8 representation.
    /// - Returns: The 32-bit FNV1a hash value
    public func fnv1a_32() -> UInt32 {
        return self.utf8.fnv1a_32()
    }
    
    /// Computes the FNV1-32 hash of the string's UTF-8 representation.
    /// - Returns: The 32-bit FNV1 hash value
    public func fnv1_32() -> UInt32 {
        return self.utf8.fnv1_32()
    }
    
    /// Computes the FNV1a-64 hash of the string's UTF-8 representation.
    /// - Returns: The 64-bit FNV1a hash value
    public func fnv1a_64() -> UInt64 {
        return self.utf8.fnv1a_64()
    }
    
    /// Computes the FNV1-64 hash of the string's UTF-8 representation.
    /// - Returns: The 64-bit FNV1 hash value
    public func fnv1_64() -> UInt64 {
        return self.utf8.fnv1_64()
    }

    #if false
    /// Computes the FNV1a-128 hash of the string's UTF-8 representation.
    /// - Returns: A tuple of (high, low) UInt64 values representing the 128-bit hash
    public func fnv1a_128() -> (high: UInt64, low: UInt64) {
        return self.utf8.fnv1a_128()
    }
    
    /// Computes the FNV1-128 hash of the string's UTF-8 representation.
    /// - Returns: A tuple of (high, low) UInt64 values representing the 128-bit hash
    public func fnv1_128() -> (high: UInt64, low: UInt64) {
        return self.utf8.fnv1_128()
    }
    #endif
}
