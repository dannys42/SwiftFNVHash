//
//  FNV1Hash.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

public struct FNV1Hash<HashType: UnsignedInteger & FixedWidthInteger & Numeric & AdditiveArithmetic>: FNVHash {
    private var hash: HashType
    private let offset: HashType
    private let prime: HashType

    public mutating func combine(_ value: UInt8) {
        self.combine([value])
    }

    public mutating func combine(_ sequence: some Sequence<UInt8>) {
        for byte in sequence {
            hash = hash &* prime
            hash ^= HashType(byte)
        }
    }

    public mutating func finalize() -> HashType {
        return hash
    }
}

public extension FNV1Hash where HashType == UInt32 {
    init() {
        self.offset = fnv32OffsetBasis
        self.prime = fnv32Prime

        self.hash = offset
    }
}

public extension FNV1Hash where HashType == UInt64 {
    init() {
        self.offset = fnv64OffsetBasis
        self.prime = fnv64Prime

        self.hash = offset
    }
}
