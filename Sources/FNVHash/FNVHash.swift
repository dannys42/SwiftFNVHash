/// A stateful, non-cryptographic Fowler–Noll–Vo hash function.
///
/// `hash(string:)` hashes a string's UTF-8 bytes; `update(data:)` incorporates
/// the supplied bytes. Treat `finalize()` as terminal and create a new value
/// before hashing more input.
public protocol FNVHash {
    associatedtype Digest: UnsignedInteger & FixedWidthInteger

    init()
    mutating func update(byte: UInt8)
    mutating func update(bufferPointer: UnsafeRawBufferPointer)
    consuming func finalize() -> Digest
}

public extension FNVHash {
    /// Returns the digest of a byte sequence.
    static func hash<S: Sequence>(data: S) -> Digest where S.Element == UInt8 {
        var hasher = Self()
        hasher.update(data: data)
        return hasher.finalize()
    }

    /// Returns the digest of a byte collection, using contiguous storage when available.
    static func hash<C: Collection>(data: C) -> Digest where C.Element == UInt8 {
        var hasher = Self()
        hasher.update(data: data)
        return hasher.finalize()
    }

    /// Returns the digest of the string's UTF-8 bytes.
    static func hash(string: String) -> Digest {
        hash(data: string.utf8)
    }

    /// Incorporates bytes from a sequence into the digest.
    mutating func update<S: Sequence>(data: S) where S.Element == UInt8 {
        for byte in data {
            update(byte: byte)
        }
    }

    /// Incorporates bytes from a collection, using contiguous storage when available.
    mutating func update<C: Collection>(data: C) where C.Element == UInt8 {
        let usedContiguousStorage: Void? = data.withContiguousStorageIfAvailable { buffer in
            update(bufferPointer: UnsafeRawBufferPointer(buffer))
        }

        if usedContiguousStorage == nil {
            for byte in data {
                update(byte: byte)
            }
        }
    }
}
