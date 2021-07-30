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
            if name.contains(".BMP") {
                print(name, terminator: ", ")
            }
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


public struct Sprite {
    public let icon: Icon
    public let size: Size
    public let offset: Point
    
    public let imageData: Data
    public let imageTransform: Data
    
    public init(icon: Icon, size: Size, offset: Point, imageData: Data, imageTransform: Data) {
        self.icon = icon
        self.size = size
        self.offset = offset
        self.imageData = imageData
        self.imageTransform = imageTransform
        
        
        printSha256(data: imageData, label: "Sprite icon: \(icon), imageData")
        printSha256(data: imageTransform, label: "Sprite icon: \(icon), imageTransform")
    }
    
    public init(icon: Icon, width: Int, height: Int, offsetX: Int, offsetY: Int, imageData: Data, imageTransform: Data) {
        self.init(
            icon: icon,
            size: .init(width: width, height: height),
            offset: .init(x: offsetX, y: offsetY),
            imageData: imageData,
            imageTransform: imageTransform
        )
    }
}
public extension Sprite {
    func data() -> Data {
        /*
         const int32_t offsetInY = inY * widthIn + inX;
              const uint8_t * imageInY = in.image() + offsetInY;
              const uint8_t * transformInY = in.transform() + offsetInY;

              const int32_t offsetOutY = outY * widthOut + outX;
              uint8_t * imageOutY = out.image() + offsetOutY;
              const uint8_t * imageInYEnd = imageInY + height * widthIn;

              if ( out.singleLayer() ) {
                  for ( ; imageInY != imageInYEnd; imageInY += widthIn, transformInY += widthIn, imageOutY += widthOut ) {
                      const uint8_t * imageInX = imageInY;
                      const uint8_t * transformInX = transformInY;
                      uint8_t * imageOutX = imageOutY;
                      const uint8_t * imageInXEnd = imageInX + width;

                      for ( ; imageInX != imageInXEnd; ++imageInX, ++transformInX, ++imageOutX ) {
                          if ( *transformInX > 0 ) { // apply a transformation
                              if ( *transformInX != 1 ) { // skip pixel
                                  *imageOutX = *( transformTable + ( *transformInX ) * 256 + *imageOutX );
                              }
                          }
                          else { // copy a pixel
                              *imageOutX = *imageInX;
                          }
                      }
                  }
              }
         */
        self.imageData
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
        data rawData: Data,
        width: Int32,
        height: Int32,
        offsetX: Int16,
        offsetY: Int16
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
            width: .init(width), height: .init(height),
            offsetX: .init(offsetX), offsetY: .init(offsetY),
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
        print("🔮 LoadOriginalICN ICN::GetString( id ): \(fileName), body.size(): \(body.count), sha256(body): \(sha256Hex(data: body))")
        let dataReader = DataReader(data: body)
        
        let count = Int(try dataReader.readUInt16())
        let blockSize = try dataReader.readUInt32()
        guard count > 0, blockSize > 0 else { throw Error.failedToLoadImageSprite }
        
        print("🔮 LoadOriginalICN count: \(count)")
        
        let sprites: [Sprite] = try (0..<count).map { i throws -> Sprite in
            try dataReader.seek(to: Self.headerSize + i * 13)
            let header1 = try dataReader.readIconHeader()
            var sizeData: UInt32 = 0
            if i + 1 != count {
                let header2 = try dataReader.readIconHeader()
                sizeData = header2.offsetData - header1.offsetData
            } else {
                sizeData = blockSize - header1.offsetData
            }
            let data = Data(body.suffix(from: Self.headerSize + Int(header1.offsetData)))
            
            assert(data.count == sizeData)
            
            let spriteDecoder = SpriteDecoder()
            let sprite = try spriteDecoder.decodeSprite(
                icon: icon,
                data: data,
                width: .init(header1.width),
                height: .init(header1.height),
                offsetX: .init(header1.offsetX),
                offsetY: .init(header1.offsetY)
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
    
    /// ✅ "IsScalableICN"
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
    
    func smallSpriteForCreature(_ icon: Icon) -> Sprite {
        try! loadOriginal(icon: icon)
        let sprites = spriteCache._spritesFor(icon: icon)
        assert(sprites.count == 1)
        return sprites[0]
    }
    
    func spriteFor(creature: Creature) throws -> Sprite {
        try spriteFor(icon: .allCreatures, creature: creature)
    }
}
