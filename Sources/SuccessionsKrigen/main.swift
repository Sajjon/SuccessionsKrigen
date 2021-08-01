import Foundation

import HoMM2Engine

import CSDL2
import CSDL2_Image

private func sdlError(prefix: String) -> String {
    let maxLen: Int32 = 1000
    var errMessage = Array<CChar>.init(repeating: 0, count: Int(maxLen))
    SDL_GetErrorMsg(&errMessage, maxLen)
    let errorMessage = String(bytes: errMessage.prefix(while: { $0 > 0 }).map(UInt8.init), encoding: String.Encoding.ascii)!
    return "\(prefix), error message: \(errorMessage) (code: \(SDL_GetError()!.pointee))"
}

private func printSDLError(prefix: String) {
    let errorMessage = sdlError(prefix: prefix)
    print(errorMessage)
}

private func sdlFatalError(reason: String, _ line: UInt = #line) -> Never {
    let errorMessage = sdlError(prefix: reason)
    fatalError(errorMessage, line: line)
}

struct ColorRGB {
    typealias Value = UInt8
    let red: Value
    let blue: Value
    let green: Value
    let alpha: Value
}

func pixelFormatFromTexture(_ texture: OpaquePointer) -> SDL_PixelFormat {
    var format: UInt32 = 0
    SDL_QueryTexture(texture, &format, nil, nil, nil)
    var pixelFormat = SDL_PixelFormat()
    pixelFormat.format = format
    return pixelFormat
}

func rgbaPixelFormat(renderer: OpaquePointer) -> SDL_PixelFormat {
    guard let dummyTexture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888.rawValue, Int32(SDL_TEXTUREACCESS_STATIC.rawValue), 64, 48) else {
        sdlFatalError(reason: "SDL_CreateTexture failed")
    }
    let pixelFormat = pixelFormatFromTexture(dummyTexture)
    SDL_DestroyTexture(dummyTexture)
    return pixelFormat
}

func mutateTexturePixels(texture: OpaquePointer, pixelColor: ColorRGB, position: Point) {
    // Get the size of the texture.
    var format: UInt32 = 0
    var pitch: Int32 = 0
    var width: Int32 = 0
    var height: Int32 = 0
    var access: Int32 = 0
    SDL_QueryTexture(texture, &format, &access, &width, &height)
    guard access == SDL_TEXTUREACCESS_STREAMING.rawValue else {
        fatalError("Must be SDL_TEXTUREACCESS_STREAMING")
    }
    
    // Now let's make our "pixels" pointer point to the texture data.
    var pixelFormat = SDL_PixelFormat()
    pixelFormat.format = format
    //    print("pixelFormat.BytesPerPixel: \(pixelFormat.BytesPerPixel)")
    // Now you want to format the color to a correct format that SDL can use.
    // Basically we convert our RGB color to a hex-like BGR color.
    var color = SDL_MapRGB(&pixelFormat, pixelColor.red, pixelColor.green, pixelColor.blue)
    // Before setting the color, we need to know where we have to place it.
    let pixelOffset = position.y * (Int(pitch)) + (position.x + MemoryLayout<UInt32>.size)
    let pixelCount = Int(width * height)
    
    
    var pixels = [UInt32](repeating: 0, count: pixelCount)
    let rawPointer: UnsafeMutableRawPointer = pixels.withUnsafeMutableBytes { $0.baseAddress! }
    let opaquePointer = OpaquePointer(rawPointer)
    
    let pixelPointer = UnsafeMutablePointer<UnsafeMutableRawPointer?>(opaquePointer)
    
    guard SDL_LockTexture(texture, nil /* rect */, pixelPointer, &pitch) == 0 else {
        fatalError(sdlError(prefix: "SDL_LockTexture failed"))
    }
    defer {
        // Also don't forget to unlock your texture once you're done.
        SDL_UnlockTexture(texture)
    }
    
    // Now we can set the pixel(s) we want.
    let pixelPointerOffsetted = pixelPointer + pixelOffset
    //    let colorPointer = UnsafePointer(&color)
    pixelPointerOffsetted.withMemoryRebound(to: UInt32.self, capacity: 1) {
        $0.assign(from: &color, count: 1)
    }
    //    pixelPointer.assign(from: colorPointer, count: 1)
    
}


func textureFromImage(data imageData: Data, isBMP: Bool = false, renderer: OpaquePointer) -> OpaquePointer? {
    let imageDataSize = Int32(imageData.count)
    let sdlDataSource: UnsafeMutablePointer<SDL_RWops> = imageData.withUnsafeBytes {
        guard
            let imageDataAddress = $0.baseAddress,
            let rwFromMem = SDL_RWFromConstMem(imageDataAddress, imageDataSize)
        else {
            sdlFatalError(reason: "SDL_RWFromConstMem failed")
        }
        return rwFromMem
    }
    
    func sdlLoadImageFromData(source: UnsafeMutablePointer<SDL_RWops>!) -> UnsafeMutablePointer<SDL_Surface>? {
        if isBMP {
            return IMG_LoadBMP_RW(source)
        } else {
            return IMG_Load_RW(source, 1 /* `1` indicates that the stream will be closed after read */)
        }
    }
    
    
    
    guard
        let imageSurface = sdlLoadImageFromData(source: sdlDataSource)
    else {
        printSDLError(prefix: "SDL_LoadFile_RW failed")
        return nil
    }
    
    defer { SDL_FreeSurface(imageSurface) }
    
    /* Upload surface to renderer, and then, free the surface */
    guard let texture = SDL_CreateTextureFromSurface(renderer, imageSurface) else {
        printSDLError(prefix: "SDL_CreateTextureFromSurface failed")
        return nil
    }
    return texture
}

func textureFromSprite(_ sprite: Sprite, renderer: OpaquePointer) -> OpaquePointer? {
    let imageData = sprite.data()
    return textureFromImage(data: imageData, renderer: renderer)
}

func textureFromImage(at filePath: String, renderer: OpaquePointer) -> OpaquePointer? {
    let isBMP = filePath.hasSuffix(".BMP")
    guard let imageDataFull = FileManager.default.contents(atPath: filePath) else {
        printSDLError(prefix: "Failed to load image data at: \(filePath)")
        return nil
    }
    //    let imageData = isBMP ? Data(imageDataFull.suffix(from: 6)) : imageDataFull
    return textureFromImage(data: imageDataFull, isBMP: isBMP, renderer: renderer)
}


// This guide / tutorial seems useful: https://github.com/libsdl-org/SDL/blob/a21e6af514bc98bcfdc812a28cd04aed992c1274/test/testrendertarget.c
// This SO answer seems good if we wanna create an empty Texture, which we can use to mutate its pixels with creature Icon sprite?
func draw(sprite: Sprite, renderer: OpaquePointer) {
    fatalError()
    /*
     void DrawMonster( fheroes2::RandomMonsterAnimation & monsterAnimation, const Troop & troop, const fheroes2::Point & offset, bool isReflected, bool isAnimated,
     const fheroes2::Rect & roi )
     {
     const fheroes2::Sprite & monsterSprite = fheroes2::AGG::GetICN( monsterAnimation.icnFile(), monsterAnimation.frameId() );
     fheroes2::Point monsterPos( offset.x, offset.y + monsterSprite.y() );
     if ( isReflected )
     monsterPos.x -= monsterSprite.x() - ( troop.isWide() ? CELLW / 2 : 0 ) - monsterAnimation.offset() + monsterSprite.width();
     else
     monsterPos.x += monsterSprite.x() - ( troop.isWide() ? CELLW / 2 : 0 ) - monsterAnimation.offset();
     
     fheroes2::Point inPos( 0, 0 );
     fheroes2::Point outPos( monsterPos.x, monsterPos.y );
     fheroes2::Size inSize( monsterSprite.width(), monsterSprite.height() );
     
     fheroes2::Display & display = fheroes2::Display::instance();
     
     if ( fheroes2::FitToRoi( monsterSprite, inPos, display, outPos, inSize, roi ) ) {
     fheroes2::Blit( monsterSprite, inPos, display, outPos, inSize, isReflected );
     }
     
     if ( isAnimated )
     monsterAnimation.increment();
     }
     */
}

func createTextureWithRenderer(
    _ renderer: OpaquePointer,
    size: Size,// = .init(width: 70, height: 70),
    access: SDL_TextureAccess = SDL_TEXTUREACCESS_TARGET
) -> OpaquePointer {
    
    let texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888.rawValue, .init(access.rawValue), Int32(size.width), Int32(size.height))!
    SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND)
    return texture
}

extension FixedWidthInteger {
    static func random() -> Self {
        return Self.random(in: 0..<Self.max)
    }
}

let standardPaletteSize = 256
func standardPaletteIndexes() -> [UInt8] {
    (0..<standardPaletteSize).map( UInt8.init )
}



let kb_pal: [UInt8] = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x3f, 0x3f, 0x3f, 0x3c, 0x3c, 0x3c, 0x3a, 0x3a, 0x3a, 0x37, 0x37, 0x37, 0x35, 0x35, 0x35, 0x32, 0x32, 0x32, 0x30, 0x30, 0x30, 0x2d, 0x2d, 0x2d,
    0x2b, 0x2b, 0x2b, 0x29, 0x29, 0x29, 0x26, 0x26, 0x26, 0x24, 0x24, 0x24, 0x21, 0x21, 0x21, 0x1f, 0x1f, 0x1f, 0x1c, 0x1c, 0x1c, 0x1a, 0x1a, 0x1a, 0x17, 0x17, 0x17,
    0x15, 0x15, 0x15, 0x12, 0x12, 0x12, 0x10, 0x10, 0x10, 0x0e, 0x0e, 0x0e, 0x0b, 0x0b, 0x0b, 0x09, 0x09, 0x09, 0x06, 0x06, 0x06, 0x04, 0x04, 0x04, 0x01, 0x01, 0x01,
    0x00, 0x00, 0x00, 0x3f, 0x3b, 0x37, 0x3c, 0x37, 0x32, 0x3a, 0x34, 0x2e, 0x38, 0x31, 0x2a, 0x36, 0x2e, 0x26, 0x34, 0x2a, 0x22, 0x32, 0x28, 0x1e, 0x30, 0x25, 0x1b,
    0x2e, 0x22, 0x18, 0x2b, 0x1f, 0x15, 0x29, 0x1c, 0x12, 0x27, 0x1a, 0x0f, 0x25, 0x18, 0x0d, 0x23, 0x15, 0x0b, 0x21, 0x13, 0x08, 0x1f, 0x11, 0x07, 0x1d, 0x0f, 0x05,
    0x1a, 0x0d, 0x04, 0x18, 0x0c, 0x03, 0x16, 0x0a, 0x02, 0x14, 0x09, 0x01, 0x12, 0x07, 0x01, 0x0f, 0x06, 0x00, 0x0d, 0x05, 0x00, 0x0b, 0x04, 0x00, 0x09, 0x03, 0x00,
    0x30, 0x33, 0x3f, 0x2b, 0x2e, 0x3c, 0x26, 0x2a, 0x3a, 0x22, 0x26, 0x38, 0x1e, 0x22, 0x36, 0x1a, 0x1e, 0x34, 0x16, 0x1a, 0x31, 0x13, 0x16, 0x2f, 0x10, 0x13, 0x2d,
    0x0d, 0x10, 0x2b, 0x0a, 0x0d, 0x29, 0x08, 0x0c, 0x26, 0x07, 0x0a, 0x24, 0x05, 0x09, 0x22, 0x04, 0x08, 0x20, 0x03, 0x07, 0x1e, 0x02, 0x06, 0x1c, 0x01, 0x05, 0x19,
    0x01, 0x05, 0x17, 0x00, 0x04, 0x15, 0x00, 0x03, 0x13, 0x00, 0x03, 0x11, 0x2b, 0x38, 0x27, 0x27, 0x35, 0x23, 0x24, 0x33, 0x20, 0x20, 0x30, 0x1c, 0x1d, 0x2e, 0x19,
    0x1a, 0x2c, 0x17, 0x17, 0x29, 0x14, 0x14, 0x27, 0x11, 0x12, 0x24, 0x0f, 0x0f, 0x22, 0x0c, 0x0d, 0x1f, 0x0a, 0x0b, 0x1d, 0x09, 0x09, 0x1b, 0x07, 0x08, 0x19, 0x06,
    0x06, 0x17, 0x05, 0x05, 0x15, 0x03, 0x03, 0x13, 0x02, 0x02, 0x10, 0x01, 0x01, 0x0e, 0x01, 0x01, 0x0c, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x08, 0x00, 0x00, 0x06, 0x00,
    0x3f, 0x3d, 0x34, 0x3e, 0x3a, 0x2b, 0x3d, 0x38, 0x23, 0x3c, 0x37, 0x1b, 0x3b, 0x35, 0x14, 0x3a, 0x33, 0x0d, 0x39, 0x32, 0x05, 0x38, 0x31, 0x00, 0x36, 0x2f, 0x08,
    0x34, 0x2c, 0x07, 0x32, 0x28, 0x06, 0x2f, 0x26, 0x06, 0x2d, 0x23, 0x06, 0x2a, 0x1f, 0x05, 0x27, 0x1c, 0x04, 0x25, 0x19, 0x03, 0x22, 0x16, 0x03, 0x1f, 0x13, 0x02,
    0x1d, 0x11, 0x02, 0x1a, 0x0f, 0x00, 0x18, 0x0c, 0x00, 0x15, 0x0a, 0x00, 0x13, 0x08, 0x00, 0x39, 0x33, 0x3e, 0x36, 0x2f, 0x3b, 0x32, 0x2a, 0x39, 0x30, 0x27, 0x36,
    0x2d, 0x23, 0x34, 0x2a, 0x1f, 0x31, 0x27, 0x1c, 0x2f, 0x24, 0x19, 0x2d, 0x21, 0x16, 0x2a, 0x1e, 0x13, 0x28, 0x1c, 0x11, 0x25, 0x19, 0x0e, 0x23, 0x17, 0x0c, 0x20,
    0x14, 0x0a, 0x1e, 0x12, 0x08, 0x1b, 0x10, 0x06, 0x19, 0x0e, 0x05, 0x17, 0x0b, 0x02, 0x14, 0x08, 0x01, 0x11, 0x06, 0x00, 0x0e, 0x04, 0x00, 0x0b, 0x2d, 0x3d, 0x3f,
    0x2a, 0x3a, 0x3c, 0x28, 0x38, 0x3a, 0x25, 0x36, 0x38, 0x22, 0x33, 0x35, 0x20, 0x31, 0x33, 0x1e, 0x2e, 0x31, 0x1c, 0x2c, 0x2f, 0x19, 0x2a, 0x2c, 0x17, 0x27, 0x2a,
    0x16, 0x25, 0x28, 0x14, 0x23, 0x25, 0x12, 0x20, 0x23, 0x10, 0x1d, 0x20, 0x0e, 0x1a, 0x1d, 0x0c, 0x18, 0x1b, 0x0a, 0x15, 0x18, 0x08, 0x13, 0x16, 0x07, 0x10, 0x13,
    0x05, 0x0e, 0x10, 0x04, 0x0b, 0x0e, 0x03, 0x09, 0x0b, 0x02, 0x07, 0x09, 0x3f, 0x39, 0x39, 0x3d, 0x34, 0x34, 0x3c, 0x2f, 0x2f, 0x3a, 0x2b, 0x2b, 0x39, 0x27, 0x27,
    0x37, 0x23, 0x23, 0x36, 0x1f, 0x1f, 0x34, 0x1b, 0x1b, 0x33, 0x17, 0x17, 0x31, 0x14, 0x14, 0x30, 0x11, 0x11, 0x2f, 0x0e, 0x0e, 0x2e, 0x0b, 0x0b, 0x2d, 0x09, 0x09,
    0x2a, 0x08, 0x08, 0x27, 0x06, 0x06, 0x24, 0x04, 0x04, 0x21, 0x03, 0x03, 0x1e, 0x02, 0x02, 0x1b, 0x01, 0x01, 0x18, 0x00, 0x00, 0x15, 0x00, 0x00, 0x12, 0x00, 0x00,
    0x3f, 0x39, 0x27, 0x3e, 0x36, 0x23, 0x3d, 0x34, 0x1f, 0x3c, 0x31, 0x1c, 0x3b, 0x2e, 0x18, 0x3a, 0x2b, 0x14, 0x39, 0x28, 0x11, 0x38, 0x24, 0x0e, 0x38, 0x21, 0x0b,
    0x33, 0x1d, 0x08, 0x2e, 0x19, 0x06, 0x29, 0x16, 0x04, 0x25, 0x12, 0x02, 0x20, 0x0f, 0x01, 0x1b, 0x0c, 0x00, 0x17, 0x0a, 0x00, 0x3f, 0x16, 0x03, 0x37, 0x0d, 0x01,
    0x30, 0x05, 0x00, 0x29, 0x00, 0x00, 0x3f, 0x3f, 0x00, 0x3f, 0x33, 0x00, 0x30, 0x23, 0x00, 0x23, 0x12, 0x00, 0x29, 0x34, 0x00, 0x25, 0x2f, 0x00, 0x21, 0x2b, 0x00,
    0x1e, 0x27, 0x01, 0x1a, 0x23, 0x01, 0x17, 0x1e, 0x01, 0x13, 0x1a, 0x01, 0x10, 0x16, 0x01, 0x0d, 0x12, 0x01, 0x0a, 0x1e, 0x34, 0x06, 0x1a, 0x31, 0x01, 0x12, 0x2d,
    0x00, 0x0e, 0x2b, 0x03, 0x15, 0x2f, 0x00, 0x0e, 0x2b, 0x00, 0x10, 0x2d, 0x21, 0x38, 0x3f, 0x00, 0x26, 0x3f, 0x00, 0x14, 0x39, 0x00, 0x00, 0x29, 0x23, 0x23, 0x2f,
    0x1c, 0x1c, 0x27, 0x15, 0x15, 0x1f, 0x0f, 0x0f, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

var palPalette_:  [UInt8] = []
func palPalette() -> [UInt8] {
    if palPalette_.isEmpty {
        palPalette_ = .init(repeating: 0xff, count: 3 * 256)
        for i in 0..<palPalette_.count {
            palPalette_[i] = kb_pal[i] << 2
        }
    }
    
    return palPalette_
}

func generatePalette(
    colorIds: [UInt8] = standardPaletteIndexes(),
    surfaceSupportsAlpha: Bool = true,
    format: UnsafePointer<SDL_PixelFormat>
) -> [UInt32] {
    
    
    var palette32Bit = [UInt32](repeating: 0xff, count: 256)
    
    let currentPalette = palPalette()
    
    //    let supportsAlpha = surface.format!.pointee.Amask > 0
    
    for i in 0..<palette32Bit.count {
        var offset = 0
        func getValue() -> UInt8 {
            defer { offset += 1 }
            return currentPalette[Int(colorIds[i]) * 3 + offset]
        }
        let red = getValue()
        let green = getValue()
        let blue = getValue()
        //        let format = surface.format
        let color = surfaceSupportsAlpha ? SDL_MapRGBA(format, red, green, blue, 255) : SDL_MapRGB(format, red, green, blue)
        palette32Bit[i] = color
    }
    
    return palette32Bit
}

func generatePixelsFromColoredDots(width: Int32, height: Int32) -> [UInt32] {
    let pixelCount = Int(width * height)
    var pixels: [UInt32] = .init(repeating: 0xffffff, count: pixelCount)
    
    for index in 0..<pixelCount {
        pixels[index] = .random()
    }
    
    return pixels
}

func testSDL() {
    
    /* Starting SDL */
    guard SDL_Init(SDL_INIT_VIDEO) == 0 else  {
        sdlFatalError(reason: "SDL_INIT_VIDEO failed")
    }
    
    /* Create a Window */
    let width: Int32 = 640
    let height: Int32 = 480
    guard let window = SDL_CreateWindow("Hello World", 0, 0, width, height, SDL_WINDOW_SHOWN.rawValue) else {
        sdlFatalError(reason: "Create Window failed")
    }
    
    /* Create a renderer */
    let flags = SDL_RENDERER_SOFTWARE.rawValue // SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue
    guard let renderer = SDL_CreateRenderer(window, -1, flags) else {
        sdlFatalError(reason: "Create Renderer failed")
    }
    
    var rendererInfo = SDL_RendererInfo()
    guard SDL_GetRendererInfo(renderer, &rendererInfo) == 0 else {
        sdlFatalError(reason: "GetRendererInfo failed")
    }
    
    guard let windowSurfaceBase = SDL_GetWindowSurface(window) else {
        sdlFatalError(reason: "SDL_GetWindowSurface failed")
    }
    let pitch = windowSurfaceBase.pointee.pitch
    SDL_FreeSurface(windowSurfaceBase)
    
    
    
    func draw(pixels: inout [UInt32], renderer targetRenderer: OpaquePointer) {
        pixels.withUnsafeMutableBytes {
            let pixelPointer: UnsafeMutableRawPointer = $0.baseAddress!
            guard let rgbSurface = SDL_CreateRGBSurfaceWithFormatFrom(pixelPointer, width, height, 32, pitch, SDL_PIXELFORMAT_RGBA8888.rawValue) else {
                sdlFatalError(reason: "SDL_CreateRGBSurfaceWithFormatFrom failed")
            }
            
            //            if surface.format!.pointee.BitsPerPixel != 32 {
            //                fatalError("Only 32 bit palette is supported at the moment")
            //            }
            //
            
            guard let textureWithPixels = SDL_CreateTextureFromSurface(targetRenderer, rgbSurface) else {
                sdlFatalError(reason: "SDL_CreateTextureFromSurface failed")
            }
            SDL_RenderCopy(targetRenderer, textureWithPixels, nil, nil)
            SDL_DestroyTexture(textureWithPixels)
            SDL_FreeSurface(rgbSurface)
        }
    }
    
    func drawRandomPixels() {
        print(".", terminator: "")
        var pixels = generatePixelsFromColoredDots(width: width, height: height)
        draw(pixels: &pixels, renderer: renderer)
    }
    
    func draw(sprite: Sprite, renderer targetRenderer: OpaquePointer) {
        
        // If the image has size as the displayed window/renderer
        let isFullFrame = sprite.size.width == width
        
        var pixelFormat = rgbaPixelFormat(renderer: targetRenderer)
        let palett32Bit: [UInt32] = generatePalette(format: &pixelFormat)
        let whiteColor: UInt32 =  0xffffffff //SDL_MapRGBA(&pixelFormat, 255, 255, 255, 255)
        print("+", terminator: "")
        let pixelCount = Int(width * height)
        var pixels: [UInt32] = .init(repeating: whiteColor, count: pixelCount)
        
        
        let transform: [UInt32] = palett32Bit
        
        if isFullFrame {
            var offset = 0
            while offset < sprite.imageData.count {
                defer {
                    offset += 1
                }
                let transformIndex = Int(sprite.imageData[offset])
                let transformedValue: UInt32 = transform[transformIndex]
                pixels[offset] = transformedValue
            }
        } else {
            var offset = 0
            for y in 0..<sprite.size.height {
                for x in 0..<sprite.size.width {
                    defer { offset += 1 }
//                    let transformIndex = Int(sprite.imageData[offset])
//                    let transformedValue: UInt32 = transform[transformIndex]
                    let rawImageData = UInt32(sprite.imageData[offset])
                    let index = y * ( Int(width) ) + x
                    print("y \(y), x: \(x), index: \(index), rawImageData: \(rawImageData)")
                    pixels[index] = rawImageData //transformedValue
                    
                }
            }
        }
        
        draw(pixels: &pixels, renderer: renderer)
    }
    
    
    func drawPhoenix() {
        let aggFile = try! AGGFile(path: AGGFile.defaultFilePathHeroes2)
        let sprite = aggFile.smallSpriteForCreature(.phoenixSmall)
        draw(sprite: sprite, renderer: renderer)
    }
    
    func drawFunStuff() {
        //        drawRandomPixels()
        drawPhoenix()
    }
    
    func doDrawFunStuff() {
        SDL_RenderClear(renderer)
        drawFunStuff()
        SDL_RenderPresent(renderer)
    }
    
    
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    SDL_RenderClear(renderer)
    SDL_RenderPresent(renderer)
    
    
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    
    doDrawFunStuff()
    
    while !quit {
        while SDL_PollEvent(&e) != 0 {
            if e.type == SDL_QUIT.rawValue {
                quit = true
            }
            
            if e.type == SDL_KEYDOWN.rawValue {
                SDL_RenderClear(renderer)
                defer { SDL_RenderPresent(renderer) } // Show renderer on window
                if e.key.keysym.sym == SDLK_q.rawValue {
                    print("Did press Quit ('Q' key)")
                    quit = true
                } else {
                    doDrawFunStuff()
                }
            }
            
            
        }
    }
    
    /* Free all objects*/
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    
    /* Quit program */
    SDL_Quit()
    
}

testSDL()
