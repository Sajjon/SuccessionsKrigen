//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation


public final class DataReader {
    private var source: Data
    private let originalSize: Int
    public private(set) var offset: Int = 0
    public init(data: Data) {
        source = data
        originalSize = data.count
    }
}


private extension DataReader {
    func parse(byteCount: Int) -> Data {
        source.droppedFirst(byteCount)
    }
    
    
    func readUInt<U>(byteCount: Int, endianess: Endianess) throws -> U where U: FixedWidthInteger & UnsignedInteger {
        let bytes = try read(byteCount: byteCount)

        let littleEndianInt = bytes.withUnsafeBytes {
            $0.load(as: U.self)
        }
        
        switch endianess {
        case .little:
            return littleEndianInt
        case .big:
            fatalError("what to do?")
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
        
        let droppedDataToReturn = source.droppedFirst(byteCount)
        offset += byteCount
        assert(droppedDataToReturn.count == byteCount)
        return droppedDataToReturn
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
    
    func seek(to offset: Int) throws {
        guard offset < originalSize else {
            throw Error.outOfBounds
        }
        guard offset >= self.offset else {
            throw Error.outOfBounds
        }
        guard offset != self.offset else { return }
        let byteCount = offset - self.offset
        
        // Discard data
        let _ = try read(byteCount: byteCount)
        
        assert(self.offset == offset)
        assert(source.count + self.offset == originalSize)
    }
    
    
}
