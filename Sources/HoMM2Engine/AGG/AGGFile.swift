//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation
import CryptoKit

public func sha256Hex(data: Data) -> String {
    var hasher = SHA256()
    hasher.update(data: data)
    return Data(hasher.finalize()).hexDescription
}

public func printSha256(data: Data, label: String = "", if condition: @autoclosure () -> Bool = { true }()) {
    let description = label.isEmpty ? "" : "(\(label))"
    let hashHex = sha256Hex(data: data)
    if condition() {
        print("SHA256 \(description): \(hashHex)")
    }
}

public struct AGGFile {
    
    public final class SpriteCache {
        // "__icnVsSprite"
        fileprivate var sprites: [[Sprite]] = .init(repeating: [], count: 906) // there are 906 different ICONs, see `ICN::LASTICN`
    }
    
    public typealias FileMetadata = (fileSize: Int, fileOffset: Int)
    private let files: [String: FileMetadata]
    private let rawData: Data
    
    /// Byte count of the raw agg file.
    public var size: Int { rawData.count }
    
    /// Number of records (files) found in this agg file.
    public var numberOfRecords: Int { files.count }
    
    // "_icnVsSprite"
    public private(set) var spriteCache = SpriteCache()
    
    public init(path: String) throws {
        guard let contentsRaw = FileManager.default.contents(atPath: path) else {
            throw Error.fileNotFound
        }
        self.rawData = contentsRaw
        var files: [String: FileMetadata] = [:]

        let size = contentsRaw.count
        let dataReader = DataReader(data: contentsRaw)
        let sizePerRecord = UInt32.byteCount * 3
        let numberOfRecordsRaw = try dataReader.readUInt16(endianess: .little)
        let numberOfRecords = Int(numberOfRecordsRaw)

        precondition(numberOfRecords * (sizePerRecord + Self.maxFilenameSize) < size)

        let nameEntriesSize = Self.maxFilenameSize * numberOfRecords

        let fileEntriesData = try dataReader.read(byteCount: numberOfRecords * sizePerRecord)
        let fileEntries = DataReader(data: fileEntriesData)
        try dataReader.seek(to: size - nameEntriesSize)
        let nameEntriesData = try dataReader.read(byteCount: nameEntriesSize)
        let nameEntries = DataReader(data: nameEntriesData)

        for _ in 0..<numberOfRecords {
            let nameData = try nameEntries.read(byteCount: Self.maxFilenameSize)
            guard let namePadded = String(data: nameData, encoding: .ascii) else { throw Error.failedToParseFileName }
            let name = String(namePadded.prefix(while: { guard let asciiValue = $0.asciiValue, asciiValue > 0 else { return false }; return true }))

            // CRC part skipped
            let _ = try fileEntries.readUInt32()

            let fileOffset = try fileEntries.readUInt32()
            let fileSize = try fileEntries.readUInt32()
            files[name] = (fileSize: Int(fileSize), fileOffset: Int(fileOffset))
//            if !(name.contains(".BMP") || name.contains(".ICN") || name.contains(".82M") || name.contains(".82M")) {
//                print(name, terminator: ", ")
//            }
        }
        

        self.files = files
    }
}


let defaultDataDirectoryPath = "/Users/sajjon/Developer/Fun/Games/HoMM/HoMM_2_Gold_GAME_FILES/DATA"
public extension AGGFile {
    static let defaultFileNameHeroes2 = "heroes2.agg"
    static let defaultFilePathHeroes2 = "\(defaultDataDirectoryPath)/\(Self.defaultFileNameHeroes2)"
    static let heroes2 = try! Self(path: Self.defaultFilePathHeroes2)
    
    /// 8.3 ASCIIZ file name + 2-bytes padding
    static let maxFilenameSize =  15
    
    func read(fileName: String) throws -> Data {
        let dataReader = DataReader(data: rawData)
        guard let fileMetadata = files[fileName] else {
            throw Error.noSuchFile(named: fileName)
        }
        try dataReader.seek(to: fileMetadata.fileOffset)
        let data = try dataReader.read(byteCount: fileMetadata.fileSize)
        return data
    }
    
}

public extension AGGFile {
    enum Error: Swift.Error {
        case fileNotFound, failedToParseFileName, noSuchFile(named: String), imageIndexTooLarge(maxForIconWas: Int, butGot: Int), failedToLoadImageSprite
    }
}

public struct Size: Equatable {
    public let width: Int
    public let height: Int
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public extension Size {
    static let zero = Self(width: 0, height: 0)
}


public struct Rect {
    public let size: Size
    public let origin: Point
    
    public init(size: Size, origin: Point = .zero) {
        self.size = size
        self.origin = origin
    }
    
    public init<I>(width: I, height: I) where I: FixedWidthInteger {
        self.init(
            size: .init(
                width: .init(width),
                height: .init(height)
            ),
            origin: .zero
        )
    }
}

public struct Sprite: Equatable {
    public enum SpriteType: Equatable {
        case single
        case series(index: Int, ofTotal: Int)
    }
    public let spriteType: SpriteType
    public let icon: Icon
    public let size: Size
    public let offset: Point
    
    private let imageData: Data
    private let imageTransform: Data
    
    public init(
        icon: Icon,
        spriteType: SpriteType,
        size: Size,
        offset: Point,
        imageData: Data,
        imageTransform: Data
    ) {
        self.icon = icon
        self.spriteType = spriteType
        self.size = size
        self.offset = offset
        self.imageData = imageData
        self.imageTransform = imageTransform
    }
    
    public init(
        icon: Icon,
        spriteType: SpriteType,
        width: Int32,
        height: Int32,
        offsetX: Int16,
        offsetY: Int16,
        imageData: Data,
        imageTransform: Data
    ) {
        self.init(
            icon: icon,
            spriteType: spriteType,
            size: .init(width: .init(width), height: .init(height)),
            offset: .init(x: .init(offsetX), y: .init(offsetY)),
            imageData: imageData,
            imageTransform: imageTransform
        )
    }
}

/*

// 0 in shadow part means no shadow, 1 means skip any drawings so to don't waste extra CPU cycles for ( tableId - 2 ) command we just add extra fake tables
// Mirror palette was modified as it was containing 238, 238, 239, 240 values instead of 238, 239, 240, 241
// size: 16 * 256
private let transformTable: [UInt8] = [
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  32,  33,  34,
    35,  36,  36,  36,  36,  36,  36,  36,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  62,
    62,  62,  62,  62,  62,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  84,  84,  84,  84,  84,  91,  92,
    93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 107, 107, 107, 107, 107, 107, 114, 115, 116, 117, 118, 119, 120, 121,
    122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 130, 130, 130, 130, 130, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
    150, 151, 151, 151, 151, 151, 151, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 174, 174, 174, 174, 174,
    174, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 197, 197, 197, 197, 197, 202, 203, 204, 205, 206,
    207, 208, 209, 210, 211, 212, 213, 213, 213, 213, 213, 214, 215, 216, 217, 218, 219, 220, 221, 225, 226, 227, 228, 229, 230, 230, 230, 230, 73,
    75,  77,  79,  81,  76,  78,  74,  76,  78,  80,  244, 245, 245, 245, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // First

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  32,
    33,  34,  35,  36,  36,  36,  36,  36,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,
    62,  62,  62,  62,  62,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  84,  84,  84,  89,  90,
    91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 107, 107, 107, 107, 112, 113, 114, 115, 116, 117, 118, 119,
    120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 130, 130, 130, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147,
    148, 149, 150, 151, 151, 151, 151, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 174, 174, 174,
    174, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 197, 197, 197, 201, 202, 203, 204, 205,
    206, 207, 208, 209, 210, 211, 212, 213, 213, 213, 213, 214, 215, 216, 217, 218, 219, 220, 221, 224, 225, 226, 227, 228, 229, 230, 230, 230, 76,
    76,  76,  76,  76,  76,  76,  76,  76,  76,  78,  244, 245, 245, 245, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Second

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,
    31,  32,  33,  34,  35,  36,  36,  36,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
    60,  61,  62,  62,  62,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  84,  84,  87,  88,
    89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 107, 107, 110, 111, 112, 113, 114, 115, 116, 117,
    118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 130, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146,
    147, 148, 149, 150, 151, 151, 151, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 174,
    174, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 197, 197, 200, 201, 202, 203, 204,
    205, 206, 207, 208, 209, 210, 211, 212, 213, 213, 213, 214, 215, 216, 217, 218, 219, 220, 221, 223, 224, 225, 226, 227, 228, 229, 230, 230, 76,
    76,  76,  76,  76,  76,  76,  76,  76,  76,  76,  243, 244, 245, 245, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Third

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,
    30,  31,  32,  33,  34,  35,  36,  36,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,
    59,  60,  61,  62,  62,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  84,  86,  87,
    88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 107, 109, 110, 111, 112, 113, 114, 115, 116,
    117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145,
    146, 147, 148, 149, 150, 151, 151, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174,
    174, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 197, 199, 200, 201, 202, 203,
    204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 213, 214, 215, 216, 217, 218, 219, 220, 221, 223, 224, 225, 226, 227, 228, 229, 230, 230, 75,
    75,  75,  75,  75,  75,  75,  75,  75,  75,  75,  243, 244, 245, 245, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Fourth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  10,  11,  11,  11,  12,  13,  13,  13,  14,  14,  15,  15,  15,  16,  17,  17,  17,  18,
    18,  19,  19,  20,  20,  20,  21,  21,  11,  37,  37,  37,  38,  38,  39,  39,  39,  40,  40,  41,  41,  41,  41,  42,  42,  19,  42,  20,  20,
    20,  20,  20,  20,  21,  12,  131, 63,  63,  63,  64,  64,  64,  65,  65,  65,  65,  65,  242, 242, 242, 242, 242, 242, 242, 242, 242, 13,  14,
    15,  15,  16,  85,  17,  85,  85,  85,  85,  19,  86,  20,  20,  20,  21,  21,  21,  21,  21,  21,  21,  10,  108, 108, 109, 109, 109, 110, 110,
    110, 110, 199, 40,  41,  41,  41,  41,  41,  42,  42,  42,  42,  20,  20,  11,  11,  131, 131, 132, 132, 132, 133, 133, 134, 134, 134, 135, 135,
    18,  136, 19,  19,  20,  20,  20,  10,  11,  11,  11,  12,  12,  13,  13,  13,  14,  15,  15,  15,  16,  17,  17,  17,  18,  18,  19,  19,  20,
    20,  11,  175, 175, 176, 176, 38,  177, 177, 178, 178, 178, 179, 179, 179, 179, 180, 180, 180, 180, 180, 180, 21,  21,  108, 108, 38,  109, 38,
    109, 39,  40,  40,  41,  41,  41,  42,  42,  42,  20,  199, 179, 180, 180, 110, 110, 40,  42,  110, 110, 86,  86,  86,  86,  18,  18,  19,  65,
    65,  65,  66,  65,  66,  65,  152, 155, 65,  242, 15,  16,  17,  19,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Fifth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  11,  12,  12,  13,  13,  14,  15,  15,  16,  16,  17,  17,  18,  19,  20,  20,  21,
    21,  22,  22,  23,  24,  24,  25,  25,  37,  37,  38,  38,  39,  39,  40,  41,  41,  41,  42,  42,  43,  43,  44,  44,  45,  45,  46,  46,  23,
    24,  24,  24,  24,  24,  131, 63,  63,  64,  64,  65,  65,  66,  66,  242, 67,  67,  68,  68,  243, 243, 243, 243, 243, 243, 243, 243, 15,  15,
    85,  85,  85,  85,  86,  86,  87,  87,  88,  88,  88,  88,  89,  24,  90,  25,  25,  25,  25,  25,  25,  37,  108, 109, 109, 110, 110, 111, 111,
    200, 200, 201, 201, 42,  43,  43,  44,  44,  44,  45,  45,  46,  46,  46,  11,  131, 132, 132, 132, 133, 133, 134, 135, 135, 136, 242, 137, 137,
    138, 243, 243, 243, 243, 243, 24,  152, 152, 153, 153, 154, 154, 155, 156, 156, 157, 158, 158, 159, 18,  19,  19,  20,  20,  21,  22,  22,  23,
    24,  37,  175, 176, 176, 177, 177, 178, 179, 179, 180, 180, 180, 181, 181, 181, 182, 182, 182, 46,  47,  47,  48,  25,  108, 109, 109, 109, 198,
    199, 199, 201, 201, 42,  43,  43,  44,  45,  46,  46,  201, 181, 182, 183, 111, 111, 202, 45,  111, 111, 87,  88,  88,  88,  88,  21,  22,  66,
    66,  68,  68,  67,  68,  68,  152, 157, 66,  69,  16,  18,  20,  21,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Sixth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  11,  12,  13,  14,  14,  15,  16,  17,  17,  18,  19,  20,  20,  21,  22,  23,  24,
    24,  25,  26,  26,  27,  28,  29,  29,  37,  37,  38,  39,  40,  40,  41,  42,  42,  43,  44,  44,  45,  46,  46,  47,  47,  48,  48,  49,  50,
    50,  27,  28,  28,  28,  63,  63,  64,  65,  65,  66,  67,  67,  68,  69,  69,  69,  70,  70,  70,  244, 71,  244, 244, 244, 244, 245, 16,  85,
    85,  86,  87,  87,  88,  88,  89,  90,  90,  91,  91,  91,  92,  93,  93,  93,  29,  29,  29,  29,  29,  37,  109, 109, 110, 111, 111, 112, 113,
    112, 112, 203, 203, 203, 44,  45,  46,  47,  47,  47,  48,  48,  49,  50,  131, 131, 132, 133, 133, 134, 135, 136, 136, 137, 137, 139, 139, 139,
    141, 141, 141, 143, 143, 245, 245, 152, 152, 153, 154, 155, 155, 156, 157, 158, 158, 159, 160, 161, 162, 163, 163, 164, 165, 165, 166, 26,  26,
    27,  175, 13,  176, 177, 178, 178, 179, 180, 181, 181, 182, 182, 183, 183, 183, 184, 184, 185, 185, 50,  50,  52,  52,  109, 109, 198, 199, 200,
    201, 201, 202, 202, 44,  45,  46,  47,  48,  48,  49,  204, 205, 185, 185, 112, 112, 204, 47,  112, 113, 88,  89,  91,  92,  93,  93,  25,  66,
    68,  69,  69,  68,  69,  69,  153, 159, 68,  71,  18,  242, 243, 24,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // Seventh

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  12,  13,  13,  14,  15,  16,  17,  17,  19,  19,  20,  21,  22,  23,  24,  24,  26,
    26,  27,  28,  28,  30,  30,  31,  32,  37,  38,  39,  39,  40,  41,  42,  43,  43,  44,  45,  46,  46,  47,  48,  49,  50,  50,  51,  52,  52,
    53,  54,  54,  30,  31,  63,  64,  64,  65,  66,  67,  68,  69,  69,  70,  71,  71,  71,  72,  72,  72,  73,  73,  73,  168, 168, 168, 85,  85,
    86,  87,  88,  88,  89,  90,  91,  91,  92,  93,  93,  94,  95,  95,  96,  96,  96,  31,  32,  32,  32,  108, 109, 198, 110, 111, 112, 113, 113,
    113, 116, 117, 118, 119, 120, 121, 47,  48,  50,  50,  51,  51,  52,  52,  131, 132, 132, 133, 134, 135, 136, 137, 137, 138, 139, 140, 141, 141,
    143, 143, 144, 145, 146, 147, 30,  152, 153, 153, 154, 155, 156, 157, 158, 158, 159, 160, 161, 162, 163, 164, 165, 165, 166, 167, 168, 169, 28,
    29,  175, 176, 177, 177, 178, 179, 180, 181, 182, 182, 183, 184, 185, 185, 185, 186, 186, 187, 50,  52,  52,  54,  55,  109, 198, 199, 200, 201,
    202, 202, 204, 204, 205, 207, 47,  49,  50,  51,  52,  206, 206, 187, 188, 113, 113, 118, 49,  222, 222, 223, 224, 225, 226, 95,  227, 228, 67,
    68,  70,  71,  69,  71,  70,  153, 65,  69,  73,  242, 22,  243, 244, 0,   0,   0,   0,   0,   0,   0,   0,   0,
    0, // Eighth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  11,  12,  12,  13,  14,  14,  15,  16,  16,  17,  18,  18,  19,  20,  242, 242, 22,
    22,  23,  243, 243, 25,  244, 244, 244, 11,  37,  38,  38,  39,  40,  40,  41,  178, 18,  19,  20,  20,  21,  21,  22,  22,  22,  22,  22,  23,
    23,  23,  23,  24,  244, 63,  63,  64,  64,  65,  65,  66,  66,  67,  67,  68,  68,  68,  69,  69,  69,  69,  69,  69,  70,  70,  70,  15,  15,
    16,  85,  86,  18,  19,  19,  20,  159, 21,  21,  161, 22,  163, 163, 163, 23,  23,  165, 165, 244, 244, 37,  108, 38,  109, 109, 110, 199, 200,
    199, 40,  41,  42,  42,  42,  43,  43,  44,  22,  22,  23,  23,  23,  23,  131, 131, 132, 132, 133, 133, 134, 134, 135, 135, 136, 136, 137, 137,
    138, 138, 139, 139, 140, 141, 244, 152, 152, 153, 153, 154, 154, 155, 155, 156, 156, 157, 158, 158, 159, 242, 159, 161, 161, 243, 243, 243, 243,
    164, 11,  175, 176, 176, 177, 177, 178, 179, 179, 180, 180, 181, 181, 182, 182, 182, 182, 183, 22,  23,  23,  23,  23,  108, 38,  38,  39,  39,
    40,  40,  41,  178, 180, 42,  44,  45,  23,  23,  23,  180, 181, 181, 183, 110, 200, 42,  45,  85,  86,  87,  87,  87,  21,  22,  22,  23,  66,
    66,  67,  68,  67,  68,  68,  153, 158, 67,  70,  64,  65,  242, 243, 159, 159, 159, 159, 159, 159, 159, 159, 159, 10, // Nineth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  11,  12,  13,  14,  14,  15,  16,  16,  17,  18,  19,  19,  20,  242, 22,  22,  243,
    243, 243, 244, 244, 244, 244, 245, 245, 37,  37,  38,  176, 39,  177, 41,  41,  42,  179, 20,  180, 45,  22,  23,  23,  24,  24,  24,  24,  25,
    25,  25,  25,  26,  26,  63,  63,  64,  64,  65,  66,  67,  67,  68,  68,  69,  69,  70,  70,  70,  70,  70,  71,  71,  71,  71,  71,  15,  85,
    85,  86,  86,  87,  20,  88,  89,  22,  161, 162, 163, 163, 164, 164, 165, 165, 166, 166, 167, 167, 167, 37,  108, 109, 109, 110, 199, 111, 111,
    200, 201, 41,  43,  43,  43,  44,  44,  46,  46,  24,  24,  25,  25,  25,  131, 131, 132, 132, 133, 134, 135, 135, 136, 136, 137, 138, 138, 139,
    139, 140, 140, 141, 141, 142, 143, 152, 152, 153, 153, 154, 155, 155, 156, 156, 157, 158, 158, 159, 159, 161, 161, 162, 162, 163, 164, 244, 244,
    244, 175, 175, 176, 177, 177, 178, 179, 179, 180, 181, 181, 182, 182, 183, 183, 183, 184, 184, 184, 25,  25,  25,  25,  108, 109, 109, 39,  40,
    41,  41,  42,  42,  43,  43,  45,  46,  47,  25,  25,  181, 182, 183, 185, 111, 111, 42,  46,  111, 87,  88,  88,  88,  22,  23,  24,  25,  66,
    67,  68,  69,  68,  69,  69,  153, 0,   68,  71,  65,  242, 242, 243, 0,   0,   0,   0,   0,   0,   0,   0,   0,   10, // Tenth

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  11,  13,  13,  14,  15,  16,  16,  17,  18,  19,  20,  21,  21,  22,  23,  243, 25,
    244, 244, 244, 28,  245, 245, 245, 31,  37,  38,  38,  39,  40,  41,  41,  42,  42,  180, 45,  46,  46,  47,  47,  25,  26,  26,  26,  26,  27,
    27,  27,  27,  27,  245, 63,  63,  64,  65,  66,  66,  67,  68,  69,  69,  70,  70,  71,  71,  72,  72,  72,  72,  72,  73,  73,  73,  16,  85,
    85,  86,  87,  88,  88,  90,  90,  91,  91,  163, 164, 164, 165, 166, 166, 167, 167, 168, 169, 169, 170, 37,  108, 109, 198, 199, 111, 112, 112,
    201, 202, 202, 43,  44,  45,  45,  46,  46,  47,  48,  26,  27,  27,  27,  131, 131, 132, 133, 134, 135, 135, 136, 137, 137, 138, 139, 139, 140,
    141, 141, 142, 143, 143, 144, 145, 152, 152, 153, 154, 155, 155, 156, 156, 158, 158, 159, 160, 160, 161, 162, 163, 164, 164, 165, 166, 166, 167,
    167, 175, 176, 176, 177, 178, 178, 179, 180, 181, 182, 182, 183, 184, 184, 184, 185, 186, 186, 50,  51,  27,  27,  27,  109, 109, 109, 40,  40,
    41,  42,  43,  43,  44,  45,  46,  47,  49,  27,  27,  182, 183, 184, 187, 112, 112, 43,  47,  112, 87,  89,  90,  91,  91,  24,  26,  26,  67,
    68,  69,  70,  69,  70,  70,  153, 0,   0,   73,  65,  242, 243, 244, 0,   0,   0,   0,   0,   0,   0,   0,   0,
    10, // Eleventh

    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   10,  11,  12,  13,  13,  14,  15,  16,  17,  18,  19,  20,  21,  21,  23,  243, 24,  25,  244,
    244, 27,  245, 245, 31,  170, 149, 149, 37,  38,  38,  39,  40,  41,  42,  42,  44,  45,  46,  46,  47,  48,  49,  50,  51,  28,  28,  28,  29,
    29,  29,  29,  29,  30,  63,  64,  65,  65,  66,  67,  68,  69,  70,  70,  71,  72,  72,  73,  73,  74,  74,  75,  75,  76,  76,  76,  85,  85,
    86,  87,  88,  89,  90,  91,  91,  92,  93,  93,  166, 166, 96,  168, 168, 169, 170, 170, 171, 171, 171, 37,  109, 109, 110, 200, 111, 112, 113,
    202, 202, 203, 44,  45,  46,  46,  47,  48,  49,  50,  51,  52,  29,  29,  131, 132, 133, 133, 134, 135, 136, 137, 138, 139, 139, 140, 141, 142,
    142, 144, 144, 145, 145, 146, 147, 152, 153, 153, 154, 155, 156, 157, 158, 159, 159, 160, 161, 162, 163, 164, 164, 165, 166, 167, 168, 168, 168,
    169, 175, 176, 177, 177, 178, 179, 180, 181, 182, 182, 183, 184, 185, 186, 186, 187, 187, 189, 189, 193, 193, 146, 146, 109, 109, 198, 199, 201,
    201, 201, 44,  205, 45,  46,  47,  48,  50,  52,  29,  183, 185, 186, 189, 112, 112, 205, 49,  222, 88,  89,  91,  92,  93,  26,  27,  28,  67,
    68,  70,  71,  69,  71,  71,  154, 0,   0,   75,  242, 242, 243, 244, 0,   0,   0,   0,   0,   0,   0,   0,   0,   10, // Twelfth

    0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  10,  10,  10,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,
    25,  26,  27,  28,  29,  30,  31,  32,  37,  37,  37,  37,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,
    54,  55,  56,  57,  58,  63,  63,  63,  63,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  85,  85,
    85,  85,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 108, 108, 108, 108, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 131, 131, 131, 131, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140,
    141, 142, 143, 144, 145, 146, 147, 152, 152, 152, 152, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
    170, 175, 175, 175, 175, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 198, 198, 198, 198, 198,
    199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 214, 215, 216, 217, 218, 219, 220, 221, 222, 222, 223, 224, 225, 226, 227, 228, 229, 231,
    232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 242, 243, 244, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, // Mirror

    0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,
    29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,
    58,  59,  60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,
    87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115,
    116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144,
    145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173,
    174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202,
    203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 188, 188, 188, 188, 118, 118, 118, 118, 222, 223, 224, 225, 226, 227, 228, 229, 230, 69,
    69,  69,  69,  69,  69,  69,  69,  69,  69,  69,  242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 // No cycle
]
*/


//private extension Sprite {
//    func dataWithTransform() -> Data {
//        let skipPixel: UInt8 = 1
//
//        let imageBytes = [UInt8](imageData)
//        let imageOutBytes = imageBytes.enumerated().compactMap { index, byte -> UInt8? in
//            let transformValue: UInt8 = imageTransform[index]
//            guard transformValue != skipPixel else {
//                return byte // return nil instead?
//            }
//
//            let shouldPerformTransform = transformValue > 0
//
//            guard shouldPerformTransform else {
//                // copy a pixel "as is"
//                return byte
//            }
//
//            // Perform transform (does not seem to be needed?)
//            let tranformTableIndex = Int(transformValue) * 256
//            let transformed = transformTable[tranformTableIndex]
//            return transformed
//        }
//        return Data(imageOutBytes)
//    }
//}

public extension Sprite {
    func data() -> Data {
        imageData  // dataWithTransform() // Transform does not seem to be needed. As in: neither `self.imageTransform`, neither `transformTable`.
    }
}

    
public extension AGGFile.SpriteCache {
    func hasSprites(icon: Icon) -> Bool {
        spriteCount(icon: icon) > 0
    }
    
    func spriteCount(icon: Icon) -> Int {
        sprites[icon.rawValue].count
    }
    
    func spriteFor(icon: Icon, creature: Creature) -> Sprite {
        sprites[icon.rawValue][creature.rawValue]
    }
    
    func _spriteFor(icon: Icon, index: Int) -> Sprite {
        sprites[icon.rawValue][index]
    }
    
    func _spritesFor(icon: Icon) -> [Sprite] {
        sprites[icon.rawValue]
    }
    
    func add(sprites: [Sprite], forIcon icon: Icon) {
        self.sprites[icon.rawValue] = sprites
    }
}

public struct IconHeader {
    
    public let offsetX: UInt16
    public let offsetY: UInt16
    public let width: UInt16
    public let height: UInt16
    
    /// used for adventure map animations, this can replace ICN::AnimationFrame
    public let animationFrames: UInt8
    
    public let offsetData: UInt32
}

private extension DataReader {
    func readIconHeader() throws -> IconHeader {
        return .init(
            offsetX: try readUInt16(),
            offsetY: try readUInt16(),
            width: try readUInt16(),
            height: try readUInt16(),
            animationFrames: try readUInt8(),
            offsetData: try readUInt32()
        )
    }
}

public struct SpriteDecoder {}
public extension SpriteDecoder {

    func decodeSprite(
        icon: Icon,
        spriteType: Sprite.SpriteType,
        data rawData: Data,
        width: UInt16,
        height: UInt16,
        offsetX: UInt16,
        offsetY: UInt16
    ) throws -> Sprite {
        let totalPixelCount = Int(width * height)
        var imageData = Data(repeating: 0, count: totalPixelCount)
        var imageTransform = Data(repeating: 1, count: totalPixelCount)
        
        var rawDataOffset  = 0
        var imageDataOffset  = 0
        var imageTransformOffset = 0
        
        var posX = 0
        
     
        func isAtEndOfData() -> Bool {
            if rawDataOffset < rawData.count - 1 { return false }
            assert(rawDataOffset == rawData.count - 1, "`index` must not be larger than `dataSize - 1`")
            assert(imageDataOffset < totalPixelCount)
            assert(imageTransformOffset < totalPixelCount)
            return true
        }
        
        func read<I>(increment: Bool = true) -> I where I: FixedWidthInteger {
            let integer = I(rawData[rawDataOffset])
            if increment {
                rawDataOffset += 1
            }
            return integer
        }
        func readInt(increment: Bool = true) -> Int { read(increment: increment) }
        
        func setImageData(to imageDataValue: UInt8, andImageTransformTo imageTransformValue: UInt8, incrementPosX: Bool = true) {
            imageData[imageDataOffset + posX] = imageDataValue
            imageTransform[imageTransformOffset + posX] = imageTransformValue
            if incrementPosX {
                posX += 1
            }
        }
        
        
        while true {
            if isAtEndOfData() {
                break
            }

            if 0 == read(increment: false) { // 0x00: end of row
                imageDataOffset += Int(width)
                imageTransformOffset += Int(width)
                posX = 0
                rawDataOffset += 1
            } else if 0x80 > read(increment: false) {  // 0x01-0x7F: repeat a pixel N times
                var pixelCount: UInt32 = read()
                while pixelCount > 0 && !isAtEndOfData() {
                    setImageData(to: read(), andImageTransformTo: 0)
                    pixelCount -= 1
                }
            } else if 0x80 == read(increment: false) { // 0x80: end of image
                break
            } else if 0xC0 > read(increment: false) { // 0xBF: empty (transparent) pixels
                posX += read() - 0x80
            } else if 0xC0 == read(increment: false) {  // 0xC0: transform layer
                rawDataOffset += 1
                let transformValue: UInt8 = read(increment: false)
                let transformType = ((transformValue & 0x3C << 6) / 255 + 2) // `1` is for skipping
                var pixelCount: UInt32 = read(increment: false) % 4
                if pixelCount == 0 {
                    rawDataOffset += 1
                    pixelCount = read(increment: false)
                }
                
                if (transformValue & 0x40 != 0) && transformType <= 15 {
                    while pixelCount > 0 {
                        imageTransform[imageTransformOffset + posX] = transformType
                        posX += 1
                        pixelCount -= 1
                    }
                } else {
                    posX += Int(pixelCount)
                }
                
                rawDataOffset += 1
            } else if 0xC1 == read(increment: false) {
                rawDataOffset += 1
                var pixelCount: UInt32 = read()
                while pixelCount > 0 {
                    setImageData(to: read(increment: false), andImageTransformTo: 0)
                    pixelCount -= 1
                }
                rawDataOffset += 1
            } else {
                let pixelCountBase = Int((read() as UInt32))
                var pixelCount = abs(pixelCountBase - 0xC0)
                while pixelCount > 0 {
                    setImageData(to: read(increment: false), andImageTransformTo: 0)
                    pixelCount -= 1
                }
                rawDataOffset += 1
            }
        }
 
        return  .init(
            icon: icon,
            spriteType: spriteType,
            width: .init(width), height: .init(height),
            offsetX: .init(bitPattern: offsetX), offsetY: .init(bitPattern: offsetY),
            imageData: imageData,
            imageTransform: imageTransform
        )
        
    }
}

private extension AGGFile {
    
    static let headerSize = 6
    
    /// "LoadOriginalICN"
    func loadOriginal(icon: Icon) throws {
        let fileName = icon.iconFileName
        let body = try read(fileName: fileName)
        var dataReader = DataReader(data: body)
        
        let count = Int(try dataReader.readUInt16())
        let blockSize = try dataReader.readUInt32()
        guard count > 0, blockSize > 0 else { throw Error.failedToLoadImageSprite }
        
        
        let sprites: [Sprite] = try (0..<count).map { i throws -> Sprite in
            let targetOffset = Self.headerSize + i * 13
            if targetOffset < dataReader.offset {
                // uh this is terrible code! Plz fix me FFS... seriously.
                dataReader = DataReader(data: body)
                try! dataReader.seek(to: targetOffset)
            } else {
                try dataReader.seek(to: targetOffset)
            }
            let header1 = try dataReader.readIconHeader()
            var sizeData: UInt32 = 0
            if i + 1 != count {
                let header2 = try dataReader.readIconHeader()
                sizeData = header2.offsetData - header1.offsetData
            } else {
                sizeData = blockSize - header1.offsetData
            }
            let data = Data((body.suffix(from: Self.headerSize +  Int(header1.offsetData))).prefix(Int(sizeData)))
            
            assert(data.count == sizeData)
            
            let spriteDecoder = SpriteDecoder()
            let sprite = try spriteDecoder.decodeSprite(
                icon: icon,
                spriteType: count == 1 ? .single : .series(index: i, ofTotal: count),
                data: data,
                width: header1.width,
                height: header1.height,
                offsetX: header1.offsetX,
                offsetY: header1.offsetY
            )
            return sprite
        }
        spriteCache.add(sprites: sprites, forIcon: icon)
    }
    
    /// "LoadModifiedICN"
    func loadModified(icon: Icon) -> Bool {
        switch icon {
        case .PHOENIX:
            fatalError("Todo Phoenix")
        case .MONH0028: // also Phoenix
            fatalError("Todo Phoenix")
        case .MONS32:
            let spritesCount = spriteCache.spriteCount(icon: icon)
            if spritesCount > 4 { // Veteran Pikeman, Master Swordsman, Champion
                fatalError("Do stuff")
            }
            if spritesCount > 6 { // Master Swordsman, Champion
                fatalError("Do stuff")
            }
            if spritesCount > 8 { // Champion
                fatalError("Do stuff")
            }
        default: break
        }
        return false
    }
    
    /// "GetMaximumICNIndex"
    func maximumIndexFor(icon: Icon) -> Int {
        if !spriteCache.hasSprites(icon: icon) && !loadModified(icon: icon) {
            try! loadOriginal(icon: icon)
        }
        assert(spriteCache.hasSprites(icon: icon))
        return spriteCache.spriteCount(icon: icon)
   
    }
    
    /// "IsScalableICN"
    func isScalable(icon: Icon) -> Bool {
        return icon == .HEROES || icon == .BTNSHNGL || icon == .SHNGANIM
    }
    
    /// "GetScaledICN"
    func scalable(icon: Icon, creature: Creature) throws -> Sprite {
        /*
         const Sprite & GetScaledICN( int icnId, uint32_t index )
               {
                   const Sprite & originalIcn = _icnVsSprite[icnId][index];

                   if ( Display::DEFAULT_WIDTH == Display::instance().width() && Display::DEFAULT_HEIGHT == Display::instance().height() ) {
                       return originalIcn;
                   }

                   if ( _icnVsScaledSprite[icnId].empty() ) {
                       _icnVsScaledSprite[icnId].resize( _icnVsSprite[icnId].size() );
                   }

                   Sprite & resizedIcn = _icnVsScaledSprite[icnId][index];

                   const double scaleFactorX = static_cast<double>( Display::instance().width() ) / Display::DEFAULT_WIDTH;
                   const double scaleFactorY = static_cast<double>( Display::instance().height() ) / Display::DEFAULT_HEIGHT;

                   const int32_t resizedWidth = static_cast<int32_t>( originalIcn.width() * scaleFactorX + 0.5 );
                   const int32_t resizedHeight = static_cast<int32_t>( originalIcn.height() * scaleFactorY + 0.5 );
                   // Resize only if needed
                   if ( resizedIcn.width() != resizedWidth || resizedIcn.height() != resizedHeight ) {
                       resizedIcn.resize( resizedWidth, resizedHeight );
                       resizedIcn.setPosition( static_cast<int32_t>( originalIcn.x() * scaleFactorX + 0.5 ), static_cast<int32_t>( originalIcn.y() * scaleFactorY + 0.5 ) );
                       Resize( originalIcn, resizedIcn, false );
                   }

                   return resizedIcn;
               }
         */
        fatalError()
    }
    
    /// "GetICN"
    func spriteFor(icon: Icon, creature: Creature) throws -> Sprite {
        let maxIndex = maximumIndexFor(icon: icon)
        guard creature.rawValue < maxIndex else {
            throw Error.imageIndexTooLarge(maxForIconWas: maxIndex, butGot: creature.rawValue)
        }
        
        if isScalable(icon: icon) {
            return try scalable(icon: icon, creature: creature)
        }
        
        return spriteCache.spriteFor(icon: icon, creature: creature)
    }
    
}

public extension AGGFile {
    
    func spritesForCreature(_ icon: Icon) -> [Sprite] {
        try! loadOriginal(icon: icon)
        let allSprites = spriteCache._spritesFor(icon: icon)
        let sprites = allSprites.filter { $0.size.height > 1 && $0.size.width > 1 }
        return sprites
    }
    
    func spriteFor(creature: Creature) throws -> Sprite {
        try spriteFor(icon: .allCreatures, creature: creature)
    }
}
