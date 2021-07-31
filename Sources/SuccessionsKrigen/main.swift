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

func generatePixelsFromColoredDots(width: Int32, height: Int32, pixelsPerDot: Int32) -> [UInt32] {
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
    
    var pixels: [UInt32] = generatePixelsFromColoredDots(width: width, height: height, pixelsPerDot: 8)
    func drawRandomPixels() {
        print(".", terminator: "")
        pixels = generatePixelsFromColoredDots(width: width, height: height, pixelsPerDot: 8)
        pixels.withUnsafeMutableBytes {
            let pixelPointer: UnsafeMutableRawPointer = $0.baseAddress!
            guard let rgbSurface = SDL_CreateRGBSurfaceWithFormatFrom(pixelPointer, width, height, 32, pitch, SDL_PIXELFORMAT_RGBA8888.rawValue) else {
                sdlFatalError(reason: "SDL_CreateRGBSurfaceWithFormatFrom failed")
            }
            guard let textureWithPixels = SDL_CreateTextureFromSurface(renderer, rgbSurface) else {
                sdlFatalError(reason: "SDL_CreateTextureFromSurface failed")
            }
            SDL_RenderCopy(renderer, textureWithPixels, nil, nil)
            SDL_DestroyTexture(textureWithPixels)
            SDL_FreeSurface(rgbSurface)
        }
        
    }
    
    
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    SDL_RenderClear(renderer)
    SDL_RenderPresent(renderer)
    
    func doDrawRandomPixels() {
        SDL_RenderClear(renderer)
        drawRandomPixels()
        SDL_RenderPresent(renderer)
    }
    
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    
    drawRandomPixels()
    
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
                    doDrawRandomPixels()
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
