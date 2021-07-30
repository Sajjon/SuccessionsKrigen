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

func drawRectangles(renderer: OpaquePointer, purpleAlpha: inout UInt8) {
   
    let size: Int32 = 70
    var textures: [OpaquePointer] = []
    func createTexture() -> OpaquePointer {
         let texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888.rawValue, .init(SDL_TEXTUREACCESS_TARGET.rawValue), size, size)!
        textures.append(texture)
        SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND)
        return texture
    }
    
    func fillTexture(_ texture: OpaquePointer, red: UInt8 = 0, green: UInt8 = 0, blue: UInt8 = 0, alpha: UInt8 = 255) {
        SDL_SetRenderTarget(renderer, texture)
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
        SDL_SetRenderDrawColor(renderer, red, green, blue, alpha)
        SDL_RenderFillRect(renderer, nil)
    }
    
    let redTexture = createTexture()
    let greenTexture = createTexture()
    let purpleTexture = createTexture()
    
    fillTexture(redTexture, red: 255)
    fillTexture(greenTexture, green: 255, alpha: 128)
    fillTexture(purpleTexture, red: 255, blue: 255, alpha: purpleAlpha)
    
    func prepareForRendering(renderer r: OpaquePointer)
    {
        SDL_SetRenderTarget(r, nil)
        SDL_SetRenderDrawBlendMode(r, SDL_BLENDMODE_BLEND)
        SDL_SetRenderDrawColor(r, 128, 128, 128, 255)
    }
    
    prepareForRendering(renderer: renderer)
    
    var rect = SDL_Rect(x: 0, y: 0, w: size, h: size)

    func copyTextureToRenderer(texture: OpaquePointer, withOffset offset: Int32) {
        rect.x = offset
        rect.y = offset
        SDL_RenderCopy(renderer, texture, nil, &rect)
    }
    
    var offset: Int32 = 20
    textures.forEach { texture in
        copyTextureToRenderer(texture: texture, withOffset: offset)
        offset += (20 + size)
        SDL_DestroyTexture(texture)
    }
}

func testSDL() {

    /* Starting SDL */
    guard SDL_Init(SDL_INIT_VIDEO) == 0 else  {
        sdlFatalError(reason: "SDL_INIT_VIDEO failed")
    }
    
    /* Create a Window */
    guard let window = SDL_CreateWindow("Hello World", 0, 0, 640, 480, SDL_WINDOW_SHOWN.rawValue) else {
        sdlFatalError(reason: "Create Window failed")
    }
    
    /* Create a renderer */
    guard let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue) else {
        sdlFatalError(reason: "Create Renderer failed")
    }

    
//    guard let windowSurface = SDL_GetWindowSurface(window) else {
//        sdlFatalError(reason: "SDL_GetWindowSurface failed")
//    }
//    print("windowSurface height: \(windowSurface.pointee.h)")
//    print("windowSurface width: \(windowSurface.pointee.w)")
    
    
//    let heroes2AggFile = AGGFile.heroes2
//    let sprite = heroes2AggFile.smallSpriteForCreature(.phoenixSmall)
    
    var purpleAlpha: UInt8 = 10
    
    func doDrawRectangles() {
        SDL_RenderClear(renderer)
        drawRectangles(renderer: renderer, purpleAlpha: &purpleAlpha)
        SDL_RenderPresent(renderer) // Show renderer on window
    }
    
    doDrawRectangles()
    
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    
    
    while !quit {
        while SDL_PollEvent(&e) != 0 {
            if e.type == SDL_QUIT.rawValue {
                quit = true
            }
            
            if e.type == SDL_KEYDOWN.rawValue {
                if e.key.keysym.sym == SDLK_q.rawValue {
                    print("Did press Quit ('Q' key)")
                    quit = true
                } else if e.key.keysym.sym == SDLK_i.rawValue {
                    purpleAlpha += 1
                    print("purpleAlpha: \(purpleAlpha)")
                    doDrawRectangles()
//                    draw(sprite: sprite, renderer: renderer, purpleAlpha: &purpleAlpha)
                } else if e.key.keysym.sym == SDLK_d.rawValue {
                    if purpleAlpha > 0 {
                        purpleAlpha -= 1
                        print("purpleAlpha: \(purpleAlpha)")
                        doDrawRectangles()
//                        draw(sprite: sprite, renderer: renderer, purpleAlpha: &purpleAlpha)
                    }
                    
                }
                
            }
            
            if e.type == SDL_MOUSEBUTTONDOWN.rawValue {
                quit = true
            }
         
        }
    }
    
    /* Free all objects*/
//    SDL_DestroyTexture(texture)
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    
    /* Quit program */
    SDL_Quit()
    
}

testSDL()
