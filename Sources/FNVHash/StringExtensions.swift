//
//  File.swift
//  FNVHash
//
//  Created by Danny Sung on 6/8/26.
//

import Foundation

extension String {
    /// Computes the FNV1a-64 hash of the string's UTF-8 representation.
    /// - Returns: The 64-bit FNV1a hash value
    public func fnv1a_64() -> UInt64 {
        return self.utf8.fnv1a_64()
    }
}
