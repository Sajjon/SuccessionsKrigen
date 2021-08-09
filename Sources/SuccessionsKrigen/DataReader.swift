//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation


public final class DataReader {
    private let source: Data
    public private(set) var offset: Int = 0
    public init(data: Data) {
        source = data
    }
}


private extension DataReader {

    func readUInt<U>(byteCount: Int, endianess: Endianess) throws -> U where U: FixedWidthInteger & UnsignedInteger {
        let bytes = try read(byteCount: byteCount)

       
        
        switch endianess {
        case .little:
            return bytes.withUnsafeBytes {
                $0.load(as: U.self)
            }
        case .big:
            var endianessSwappedBytes = bytes
            endianessSwappedBytes.reverse()
            return endianessSwappedBytes.withUnsafeBytes {
                $0.load(as: U.self)
            }
        }
    }
    
    func readInt<I>(byteCount: Int, endianess: Endianess) throws -> I where I: FixedWidthInteger & SignedInteger {
        let bytes = try read(byteCount: byteCount)

        let littleEndianInt = bytes.withUnsafeBytes {
            $0.load(as: I.self)
        }
        
        switch endianess {
        case .little:
            return littleEndianInt
        case .big:
            fatalError("what to do?")
        }
    }
}



public enum Endianess {
    case big, little
    
}

public extension DataReader {
    
    enum Error: Swift.Error {
        case outOfBounds
    }
    
    func readUInt8(endianess: Endianess = .little) throws -> UInt8 {
        try readUInt(byteCount: 1, endianess: endianess)
    }
    
    
    func readInt8(endianess: Endianess = .little) throws -> Int8 {
        try readInt(byteCount: 1, endianess: endianess)
    }
    
    func readUInt16(endianess: Endianess = .little) throws -> UInt16 {
        try readUInt(byteCount: 2, endianess: endianess)
    }
    
    func readInt16(endianess: Endianess = .little) throws -> Int16 {
        try readInt(byteCount: 2, endianess: endianess)
    }
    
    func readUInt32(endianess: Endianess = .little) throws -> UInt32 {
        try readUInt(byteCount: 4, endianess: endianess)
    }
    
    func readInt32(endianess: Endianess = .little) throws -> Int32 {
        try readInt(byteCount: 4, endianess: endianess)
    }
    
    
    func read(byteCount: Int) throws -> Data {
        guard source.count >= byteCount else {
            throw Error.outOfBounds
        }
        let startIndex = Data.Index(offset)
        let endIndex = startIndex.advanced(by: byteCount)
        assert(endIndex <= source.count, "'source.count': \(source.count), but 'endIndex': \(endIndex)")
        self.offset += byteCount
        return Data(source[startIndex..<endIndex])
        
//
//        let bytes =  parse(byteCount: byteCount) //source.droppedFirst(byteCount)
////        offset += byteCount
//        assert(droppedDataToReturn.count == byteCount)
//        return droppedDataToReturn
    }
    
    func readInt(endianess: Endianess = .little) throws -> Int {
        try readInt(byteCount: MemoryLayout<Int>.size, endianess: endianess)
    }
    
    func readFloat() throws -> Float {
        var floatBytes = try read(byteCount: 4)
        let float: Float = floatBytes.withUnsafeMutableBytes {
            $0.load(as: Float.self)
        }
        return float
    }
    
    func seek(to targetOffset: Int) throws {
        guard targetOffset < source.count else {
            throw Error.outOfBounds
        }
//        guard offset >= self.offset else {
//            throw Error.outOfBounds
//        }
//        guard offset != self.offset else { return }
//        let byteCount = offset - self.offset
//
//        // Discard data
//        let _ = try read(byteCount: byteCount)
//
//        assert(self.offset == offset)
//        assert(source.count + self.offset == originalSize)
        self.offset = targetOffset
    }
    
    func skip(byteCount: Int) throws {
        // Discard data
        let _ = try read(byteCount: byteCount)
    }
    
    func readUntilZero() throws -> Data {
        var bytes = [UInt8]()
        while true {
            let byte = try readUInt8()
            guard byte != 0x00 else {
                break
            }
            bytes.append(byte)
        }
        return Data(bytes)
    }
    
    func readStringUntilNullTerminator(encoding: String.Encoding = .utf8) throws -> String {
        let bytes = try readUntilZero()
        guard let string = String(bytes: bytes, encoding: encoding) else {
            fatalError("no string")
        }
        return string
    }
    
    func readString(byteCount: Int, encoding: String.Encoding = .utf8) throws -> String {
        let bytes = try read(byteCount: byteCount)
        guard let nonTrimmedString = String(bytes: bytes, encoding: encoding) else {
            fatalError("no string")
        }
        return nonTrimmedString.trimmingCharacters(in: .null)
    }
}

private extension CharacterSet {
    static let null = Self([.init(0x00)])
}
