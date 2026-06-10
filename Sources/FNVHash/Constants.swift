//
//  File.swift
//  FNVHash
//
//  Created by Danny Sung on 6/9/26.
//

import Foundation

// FNV-32 constants
internal let fnv32OffsetBasis: UInt32 = 0x811c9dc5
internal let fnv32Prime: UInt32 = 0x01000193

// FNV-64 constants
internal let fnv64OffsetBasis: UInt64 = 0xcbf29ce484222325
internal let fnv64Prime: UInt64 = 0x100000001b3

// FNV-128 constants (stored as two UInt64s: high and low)
internal let fnv128OffsetBasisHigh: UInt64 = 0x6c822979b8d4e2f5
internal let fnv128OffsetBasisLow: UInt64 = 0x62b821756295c58d
internal let fnv128PrimeHigh: UInt64 = 0x0000000001000000
internal let fnv128PrimeLow: UInt64 = 0x00000100000001b3
