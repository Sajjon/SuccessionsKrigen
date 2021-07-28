//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-07-22.
//

import Foundation


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
}

public struct Sprite {
    public let size: Size
    public let offset: Point
    
    public let imageData: Data
    public let imageTransform: Data
    
    public init(size: Size, offset: Point, imageData: Data, imageTransform: Data) {
        self.size = size
        self.offset = offset
        self.imageData = imageData
        self.imageTransform = imageTransform
    }
    
    public init(width: Int, height: Int, offsetX: Int, offsetY: Int, imageData: Data, imageTransform: Data) {
        self.init(
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


extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
    
    var byteArrayLittleEndian: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}

public struct SpriteDecoder {}
public extension SpriteDecoder {

    func decodeSprite(
        data: Data,
        width: Int,
        height: Int,
        offsetX: Int,
        offsetY: Int
    ) throws -> Sprite {
        
        var imageData = Data()
        var imageTransform = Data()
     
        /*
         Sprite decodeICNSprite( const uint8_t * data, uint32_t sizeData, const int32_t width, const int32_t height, const int16_t offsetX, const int16_t offsetY )
             {
                 Sprite sprite( width, height, offsetX, offsetY );
                 sprite.reset();

                 uint8_t * imageData = sprite.image();
                 uint8_t * imageTransform = sprite.transform();

                 uint32_t posX = 0;

                 const uint8_t * dataEnd = data + sizeData;
*/
        
        let dataSize = data.count
        var index = 0
//        let dataReader = DataReader(data: data)
        var posX: UInt32 = 0
        func isAtEndOfData() -> Bool {
            if index < dataSize - 1 { return false }
            assert(index == dataSize - 1, "`index` must not be larger than `dataSize - 1`")
            return true
        }
        while true {
//            let byte = try dataReader.readUInt8()
            if data[index] == 0 { // 0x00: end of row
                imageData.append(width.data)
                imageTransform.append(width.data)
                posX = 0
                index += 1
            } else if data[index] < 0x80 {  // 0x01-0x7F: repeat a pixel N times
                var pixelCount = Int(data[index])
                index += 1
                while pixelCount > 0 && !isAtEndOfData() {
                    imageData[Int(posX)] = data[index]
                    imageTransform[Int(posX)] = 0
                    posX += 1
                    index += 1
                    pixelCount -= 1
                }
            } else if data[index] == 0x80 { // 0x80: end of image
                break
            } else if data[index] < 0xC0 { // 0xBF: empty (transparent) pixels
                posX += UInt32(data[index]) - 0x80
                index += 1
            } else if data[index] == 0xC0 {  // 0xC0: transform layer
                index += 1
                let transformValue = data[index]
                let transformType = ((transformValue & 0x3C << 6) / 255 + 2) // `1` is for skipping
                var pixelCount = data[index] % 4
                if pixelCount == 0 {
                    index += 1
                    pixelCount = data[index]
                }
                
                if (transformValue & 0x40 != 0) && transformType <= 15 {
                    while pixelCount > 0 {
                        imageTransform[Int(posX)] = transformType
                        posX += 1
                        pixelCount -= 1
                    }
                } else {
                    posX += UInt32(pixelCount)
                }
                
                index += 1
            } else if data[index] == 0xC1 {
                index += 1
                var pixelCount = data[index]
                index += 1
                while pixelCount > 0 {
                    imageData[Int(posX)] = data[index]
                    imageTransform[Int(posX)] = 0
                    posX += 1
                    pixelCount -= 1
                }
                index += 1
            } else {
                var pixelCount = data[index] - 0xC0
                index += 1
                while pixelCount > 0 {
                    imageData[Int(posX)] = data[index]
                    imageTransform[Int(posX)] = 0
                    posX += 1
                    pixelCount -= 1
                }
                index += 1
            }
            
            if index >= dataSize - 1 {
                break
            }
        }
 
        return  .init(
            width: width, height: height,
            offsetX: offsetX, offsetY: offsetY,
            imageData: imageData,
            imageTransform: imageTransform
        )
        
    }
}

private extension AGGFile {
    
    static let headerSize = 6
    
  
    
    /// "LoadOriginalICN"
    func loadOriginal(icon: Icon) throws {
        let body = try read(fileName: icon.iconFileName)
        let dataReader = DataReader(data: body)
        
        let count = Int(try dataReader.readUInt16())
        let blockSize = try dataReader.readUInt32()
        guard count > 0, blockSize > 0 else { throw Error.failedToLoadImageSprite }
        
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
            var data = Data()
            data.append(body)
            data.append(Self.headerSize.data)
            data.append(header1.offsetData.data)
            
            assert(data.count == sizeData, "data.count \(data.count) != sizeData \(sizeData)") // else drop
            
            let spriteDecoder = SpriteDecoder()
            let sprite = try spriteDecoder.decodeSprite(
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
    
    func spriteFor(creature: Creature) throws -> Sprite {
        try spriteFor(icon: .allCreatures, creature: creature)
    }
}
