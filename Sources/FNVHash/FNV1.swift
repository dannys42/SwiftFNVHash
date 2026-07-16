/// The Fowler–Noll–Vo FNV-1 family.
public enum FNV1 {
    public struct Hash32: FNVHash {
        private var state: UInt32 = fnv32OffsetBasis

        public init() {}

        public mutating func update(byte: UInt8) {
            state = state &* fnv32Prime
            state ^= UInt32(byte)
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state = state &* fnv32Prime
                state ^= UInt32(byte)
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
            state = state &* fnv64Prime
            state ^= UInt64(byte)
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state = state &* fnv64Prime
                state ^= UInt64(byte)
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
            state = state &* fnv128Prime
            state ^= UInt128(byte)
        }

        public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
            for byte in bufferPointer {
                state = state &* fnv128Prime
                state ^= UInt128(byte)
            }
        }

        public consuming func finalize() -> UInt128 {
            // Match Swift.Hasher semantics: finalization is terminal even though FNV state could continue.
            state
        }
    }
}
