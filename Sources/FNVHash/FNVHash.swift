/// A stateful Fowler–Noll–Vo hash function.
public protocol FNVHash {
    associatedtype Digest: UnsignedInteger & FixedWidthInteger

    init()
    mutating func update(byte: UInt8)
    mutating func update(bufferPointer: UnsafeRawBufferPointer)
    consuming func finalize() -> Digest
}

public extension FNVHash {
    static func hash<S: Sequence>(data: S) -> Digest where S.Element == UInt8 {
        var hasher = Self()
        hasher.update(data: data)
        return hasher.finalize()
    }

    static func hash<C: Collection>(data: C) -> Digest where C.Element == UInt8 {
        var hasher = Self()
        hasher.update(data: data)
        return hasher.finalize()
    }

    static func hash(string: String) -> Digest {
        hash(data: string.utf8)
    }

    mutating func update<S: Sequence>(data: S) where S.Element == UInt8 {
        for byte in data {
            update(byte: byte)
        }
    }

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
