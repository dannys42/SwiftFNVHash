import Testing
import Utilities

@Test("integer hex uses full width")
func fixedWidthIntegerHex() {
    #expect(UInt32(1).asHexString == "00000001")
    #expect(UInt64(1).asHexString == "0000000000000001")
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, macCatalyst 18, visionOS 2, *) {
        #expect(UInt128(1).asHexString == "00000000000000000000000000000001")
    }
}

@Test("byte hex pads each byte")
func fixedWidthByteHex() {
    #expect([UInt8(0), 1, 15, 16, 255].asHexString == "00010f10ff")
}
