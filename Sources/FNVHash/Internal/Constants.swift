import Foundation

// FNV-32 constants
internal let fnv32OffsetBasis: UInt32 = 0x811c9dc5
internal let fnv32Prime: UInt32 = 0x01000193

// FNV-64 constants
internal let fnv64OffsetBasis: UInt64 = 0xcbf29ce484222325
internal let fnv64Prime: UInt64 = 0x100000001b3

// FNV-128 constants
@available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *)
internal let fnv128OffsetBasis: UInt128 = 0x6c62272e07bb0142_62b821756295c58d
@available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *)
internal let fnv128Prime: UInt128 = 0x0000000001000000_000000000000013b
