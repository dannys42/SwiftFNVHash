//
//  FNV1aHash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

import Foundation

protocol FNVHash {
    associatedtype HashType: UnsignedInteger & FixedWidthInteger & Numeric & AdditiveArithmetic

    mutating func combine(_ sequence: some Sequence<UInt8>)
    mutating func finalize() -> HashType
}

extension FNVHash {
    public mutating func combine(_ value: String) {
        self.combine(value.utf8)
    }
}
