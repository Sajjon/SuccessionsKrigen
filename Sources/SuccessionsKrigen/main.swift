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

func testSDL() {
    let heroes2AggFile = AGGFile.heroes2
    //            let backgroundImageDataFull = heroes2AggFile.dataFor(icon: .mainMenuBackground)
    //        let backgroundImageData = Data(backgroundImageDataFull.suffix(from: 6))
//    let hommSpellBMP = try! heroes2AggFile.read(fileName: "SPELBW04.BMP")

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

    /* Draw the renderer on window */
    SDL_RenderClear(renderer) // Fill renderer with color
    
//    guard
//        let texture = textureFromImage(
//            at: "/Users/sajjon/Developer/Fun/Games/HoMM/SuccessionsKrigen/Sources/SuccessionsKrigen/homm2_battle.png",
//            renderer: renderer
//    ) else {
//        fatalError("Failed to create image texture from image.")
//    }
    
//    guard
//        let texture = textureFromImage(
//            data: hommSpellBMP,
//            isBMP: true,
//            renderer: renderer
//    ) else {
//        fatalError("Failed to create image texture from image.")
//    }
    
    let sprite = heroes2AggFile.phoenixIcon()
    
    guard
        let texture = textureFromSprite(sprite, renderer: renderer) else {
          fatalError("Failed to create image texture from image.")
      }
    
    SDL_RenderCopy(renderer, texture, nil, nil) // Copy the texture into renderer
    SDL_RenderPresent(renderer) // Show renderer on window
    
    /* Wait some seconds */
    var e: SDL_Event = SDL_Event(type: 1)
    var quit = false
    while !quit {
        while SDL_PollEvent(&e) != 0 {
            if e.type == SDL_QUIT.rawValue {
                quit = true
            }
            
            if e.type == SDL_KEYDOWN.rawValue {
                quit = true
            }
            
            if e.type == SDL_MOUSEBUTTONDOWN.rawValue {
                quit = true
            }
        }
    }
    
    /* Free all objects*/
    SDL_DestroyTexture(texture)
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    
    /* Quit program */
    SDL_Quit()
    
}

testSDL()
