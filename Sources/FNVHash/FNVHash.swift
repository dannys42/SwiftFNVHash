//
//  FNV1aHash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

import Foundation

/// A protocol that defines the interface for Fowler-Noll-Vo (FNV) hash functions.
///
/// The FNV hash functions are non-cryptographic hash functions designed for fast hashing
/// of data while maintaining good distribution properties. This protocol provides a
/// common interface for both FNV-1 and FNV-1a variants.
///
/// ## Overview
///
/// Conforming types must implement the `combine(_:)` and `finalize()` methods.
/// The `combine(_:)` method accumulates data into the hash state, while `finalize()`
/// returns the final computed hash value.
///
/// ## Topics
///
/// ### Required Methods
///
/// - ``combine(_:)``
/// - ``finalize()``
///
/// ### Convenience Methods
///
/// - ``combine(_:)``
public protocol FNVHash {
    /// The numeric type used to represent the hash value.
    ///
    /// Currently only `UInt32` and `UInt64` are supported.
    associatedtype HashType: UnsignedInteger & FixedWidthInteger & Numeric & AdditiveArithmetic

    /// Incorporates a sequence of bytes into the hash computation.
    ///
    /// This method processes each byte in the sequence and updates the internal hash state.
    /// Call this method one or more times to add data to the hash, then call ``finalize()``
    /// to get the resulting hash value.
    ///
    /// - Parameter sequence: A sequence of `UInt8` values to hash.
    mutating func combine(_ sequence: some Sequence<UInt8>)
    
    /// Finalizes the hash computation and returns the hash value.
    ///
    /// After calling this method, the hash state is consumed. To compute another hash,
    /// create a new instance.
    ///
    /// - Returns: The computed hash value.
    mutating func finalize() -> HashType
}

extension FNVHash {
    /// Incorporates a string's UTF-8 representation into the hash computation.
    ///
    /// This method converts the string to its UTF-8 byte representation and
    /// passes it to ``combine(_:)``.
    ///
    /// - Parameter value: The string to hash.
    public mutating func combine(_ value: String) {
        self.combine(value.utf8)
    }
}
