/// The Fowler–Noll–Vo FNV-1a family.
public enum FNV1a {
    public struct Hash32: FNVHash {
        private var state: UInt32 = fnv32OffsetBasis

        public init() {}

        public mutating func update(byte: UInt8) {
            state ^= UInt32(byte)
            state = state &* fnv32Prime
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state ^= UInt32(byte)
                state = state &* fnv32Prime
            }
        }

        public consuming func finalize() -> UInt32 {
            // Match Swift.Hasher semantics: finalization is terminal even though FNV state could continue.
            state
        }
    }

    public struct Hash64: FNVHash {
        private var state: UInt64 = fnv64OffsetBasis

        public init() {}

        public mutating func update(byte: UInt8) {
            state ^= UInt64(byte)
            state = state &* fnv64Prime
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state ^= UInt64(byte)
                state = state &* fnv64Prime
            }
        }

        public consuming func finalize() -> UInt64 {
            // Match Swift.Hasher semantics: finalization is terminal even though FNV state could continue.
            state
        }
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *)
    public struct Hash128: FNVHash {
        private var state: UInt128 = fnv128OffsetBasis

        public init() {}

        public mutating func update(byte: UInt8) {
            state ^= UInt128(byte)
            state = state &* fnv128Prime
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state ^= UInt128(byte)
                state = state &* fnv128Prime
            }
        }

        public consuming func finalize() -> UInt128 {
            // Match Swift.Hasher semantics: finalization is terminal even though FNV state could continue.
            state
        }
    }
}
